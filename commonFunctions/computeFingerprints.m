%Function computin two types of fingerprints from the input video using the frame based approach: 
%A fingerprint from all the I frames in the videos : fpIframes
%A fingerprint from all the frames (I + B + P) in the video

function videoFingerprints = computeFingerprints(videoFile)
%loading the videos
fpVideoProps = loadVideoToDisk(videoFile);
fileName = videoFile(1:length(videoFile)-4);
%computing the fingerprint from I frames
nberFrames = fpVideoProps.nbFrames;
indices = 1:nberFrames;
IframeIndices = indices(fpVideoProps.framesType == 'I');
%computing fingerprint from I frames
fpIframes = fingerprintFromSelectedFrames(videoFile,IframeIndices,fpVideoProps);
%computing fingerprint from I frames and selected frames
fpAllFrames = fingerprintFromSelectedFrames(videoFile,indices,fpVideoProps);
%computing fingerprint from other frames (except for I)
OtherframeIndices = indices(fpVideoProps.framesType ~= 'I');
fpOtherFrames = fingerprintFromSelectedFrames(videoFile,OtherframeIndices,fpVideoProps);
%returning the structure with the fingerprints
videoFingerprints = struct('fpIframes',fpIframes,'fpAllFrames',fpAllFrames,'fpOtherFrames',fpOtherFrames);
%save(strcat(fileName,'Fingerprints.mat'),'videoFingerprints');%saving the fingerprint in a .mat file
%unloading the video from the disk
unloadVideoFromDisk(videoFile);
end

