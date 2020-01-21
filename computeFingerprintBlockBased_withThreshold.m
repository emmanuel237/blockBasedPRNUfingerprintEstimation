%Function computing the fingerprint from an input video using the block
%based approach
%Recieves as input : 
%@videoPath : the paht to the input video
%frameIncides : array containing the list of frames which are to be used
%for fingerprint estimation
%@frameMask : array of matrices containing each frame's mask
%@videoParams : parameters of the input video
%function fingerprint = computeFingerprintBlockBased_with_Threshold(videoPath,frameIndices,frameMasks,videoParams,thresold)
function fingerprint = computeFingerprintBlockBased_withThreshold(videoPath,frameIndices,frameMasks,videoParams,threshold)

frameMasks = frameMasks >=  threshold;
%selecting the frames for the fingerprint estimation
RP = getFingerprintBlockBased(videoPath,frameIndices, frameMasks,videoParams);
RP = rgb2gray1(RP);
sigmaRP = std2(RP);
fingerprint = WienerInDFT(RP,sigmaRP);

end
