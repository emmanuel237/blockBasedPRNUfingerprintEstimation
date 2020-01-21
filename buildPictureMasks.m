%Function building frame masks and returning frame id
%The function recieves as input argument an xml file containing the
%decoding trace and the size of the video
%function [frameMasks, frameIds] = buildPictureMasks(xmlTraceFile, videoHeight, videoWidth)
function [frameMasks, frameIds] = buildPictureMasks(xmlTraceFile, videoHeight, videoWidth)


decodTraceXmlData = xmlread(xmlTraceFile);
frameDecodeTrace = decodTraceXmlData.getElementsByTagName('FrameDecodeTrace');
decodeTraceMainNode = frameDecodeTrace.item(0);
pictureElements = decodeTraceMainNode.getElementsByTagName('Picture');
nberPictures = pictureElements.getLength;
%creating buffer memories
frameIds = zeros(nberPictures,1);
frameMasks = zeros(videoHeight, videoWidth, nberPictures);
%processing all the frames trace
for n = 0 : nberPictures - 1
currentPicture = pictureElements.item(n);
[currentFrameMask, currentFrameId] = buildFrameMask(currentPicture, videoHeight, videoWidth);   

frameMasks(:,:, n + 1) = currentFrameMask;
frameIds(n+1) = currentFrameId;
end


end

