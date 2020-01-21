% -------------------------------------------------------------------------
%Function computing the fingperprint from the input video using the
%Macroblocks selection approach.
% Input arguments : 
%                   -The complete path to the video, the frames indices,
%                   the frame mask and the video parameters,and sigma
% Output arguments : the estimated reference noise pattern and the linear
% pattern
%function [RP,LP] = computeFingerprintBlockBased(videoPath,frameIndices,frameMasks,videoParams,sigma) 
%On the 28/06/2018 Modified the code to saturate pixels where there is no
%PRNU noise giving them a value of 255 so that they will be eliminated by
%the function saturate.
function [RP,LP] = getFingerprintBlockBased(videoPath,frameIndices,frameMasks,videoParams,sigma) 
database_size = length(frameIndices);             % Number of images
if database_size==0, error(' The list of frames is void !!!!'); end
if nargin<5, sigma = 3; end                 % local std of extracted noise

%%%  Parameters used in denoising filter
L = 4;                                      %  number of decomposition levels
qmf = MakeONFilter('Daubechies',8);   
t=0; 
rotArg = getRotationArg(videoPath);%getting the frame rotation parameter
for i=1:database_size
    SeeProgress(i),
    X = readFrameFromDisk(videoPath,frameIndices(i),videoParams); 
    if rotArg > 0
        X = rot90(X,rotArg);
    end
    frameMask = frameMasks(:,:,frameIndices(i));
    X = double255(X);
    if t==0
        [M,N,three]=size(X);
        if three==1 
            continue;                           % only color images will be processed    
        end
        %%%  Initialize sums 
        for j=1:3
            RPsum{j}=zeros(M,N,'single');   
            NN{j}=zeros(M,N,'single');        	% number of additions to each pixel for RPsum
        end
    else
        s = size(X);
        if length(size(X))~=3, 
            fprintf('Not a color image - skipped.\n');
            continue;                           % only color images will be used 
        end
        if any([M,N,three]~=size(X))
            fprintf('\n Skipping image of size %d x %d x %d \n',s(1),s(2),s(3));
            continue;                           % only same size images will be used 
        end
    end
    % The image will be the t-th image used for the reference pattern RP
    t=t+1;                                      % counter of used images
    
    for j=1:3
        ImNoise = single(NoiseExtract(X(:,:,j),qmf,sigma,L)); 
        Inten = single(IntenScale(X(:,:,j))).*Saturation(X(:,:,j));    % zeros for saturated pixels
        RPsum{j} = RPsum{j}+(ImNoise.*Inten).*double(frameMask);   	% weighted average of ImNoise (weighted by Inten)
        Inten = Inten.*double(frameMask);
        NN{j} = NN{j} + Inten.^2;
    end
    
end



clear ImNoise Inten X
if t==0, error('None of the images was color image in landscape orientation.'), end
RP = cat(3,RPsum{1}./(NN{1}+1),RPsum{2}./(NN{2}+1),RPsum{3}./(NN{3}+1));
% Remove linear pattern and keep its parameters
[RP,LP] = ZeroMeanTotal(RP);
RP = single(RP);               % reduce double to single precision          

    
%%% FUNCTIONS %%
function X=double255(X)
% convert to double ranging from 0 to 255
datatype = class(X);
    switch datatype,                % convert to [0,255]
        case 'uint8',  X = double(X);
        case 'uint16', X = double(X)/65535*255;  
    end


