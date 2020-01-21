videoPath = './testVideo/testVid.mp4';
outputFilePath = './output/videoMasks_and_Fingerprint.mat';
nberSlaves = 4;
framesChunckSize = 8;
threshold = 1;
localVideoPath = './temp';

% buildSaveVideoFrameMasks_withThreshold_and_Fingerprint(videoPath, outputFilePath,nberSlaves,framesChunckSize,threshold,localVideoPath)
buildSaveVideoFrameMasks_withThreshold_and_Fingerprint(videoPath, outputFilePath,nberSlaves,framesChunckSize,threshold,localVideoPath)