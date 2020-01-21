%function returning the a read frame from the disk, this frame has been
%previously written to the disk by the function loadVideoDisk
%The function takes as argument : 
%-the path to the target video file
%-the indice of the frame which is to be read
%-the video's parameters as returned by the function returned by
%videoLoadFromDisk
%returns the read three channels color frame
%function [frame, fileName] = readFrameFromDisk(videoPath, frameIndice, videoParams )
function [frame, fileName] = readFrameFromDisk(videoPath, frameIndice, videoParams)
%the function identifies the type of frames and determines from which folder it
%has to be fetched and the file name in the folder
frameIndices = 1:videoParams.nbFrames;
IframeIndices = frameIndices(videoParams.framesType == 'I');
PframeIndices = frameIndices(videoParams.framesType == 'P');
BframeIndices = frameIndices(videoParams.framesType == 'B');
frameType = videoParams.framesType(frameIndice);

framesPath = videoPath(1:length(videoPath)-4);
framesPath = strcat(framesPath,'Frames');
%switching to wright section according to type of frame
switch frameType
    case 'P'
        %looking for the image index in the array of frames
        imageIndice = (PframeIndices == frameIndice);
        imageIndice = find(imageIndice);  
        %file name construction
        fileName = strcat(framesPath,'/PBframes/Pframe',num2str(imageIndice),'.bmp');
    case 'B'
        imageIndice = (BframeIndices == frameIndice);
        imageIndice = find(imageIndice);  
        %file name construction
        fileName = strcat(framesPath,'/PBframes/Bframe',num2str(imageIndice),'.bmp');
    case 'I'             
        imageIndice = (IframeIndices == frameIndice);
        imageIndice = find(imageIndice);  
        %file name construction
        fileName = strcat(framesPath,'/Iframes/Iframe',num2str(imageIndice),'.bmp');        
    
end

frame = imread(fileName);

end

