
%function returning the  name of image representing a given frame
%takes as input arguments the frame indice and parameters of the video
%return the file name corresponding to the input file

function frameImageName = getFrameImageFileName(frameIndice, videoParams)

frameIndices = 1:videoParams.nbFrames;
IframeIndices = frameIndices(videoParams.framesType == 'I');
PframeIndices = frameIndices(videoParams.framesType == 'P');
BframeIndices = frameIndices(videoParams.framesType == 'B');
frameType = videoParams.framesType(frameIndice);

%switching to  the right section according to type of frame
switch frameType
    case 'P'
        %looking for the image index in the array of frames
        imageIndice = (PframeIndices == frameIndice);
        imageIndice = find(imageIndice);  
        %file name construction
        fileName = strcat('Pframe',num2str(imageIndice),'.bmp');
    case 'B'
        imageIndice = (BframeIndices == frameIndice);
        imageIndice = find(imageIndice);  
        %file name construction
        fileName = strcat('Bframe',num2str(imageIndice),'.bmp');
    case 'I'             
        imageIndice = (IframeIndices == frameIndice);
        imageIndice = find(imageIndice);  
        %file name construction
        fileName = strcat('Iframe',num2str(imageIndice),'.bmp');        
    
 end

frameImageName = fileName;

end

