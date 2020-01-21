%This function extracts the fingerprint from a given video using the
%specifieds frame numbers given as parameter
%Input argument 
% -videoPath : path to video from which the fingerprint is to be extracted 
% -selectedFrames : frame indices to be used for fingerprint extraction
% - the video parameters as returned by the loadVideoToDisk function
%Return value 
%- matrix containing the computed fingerprint
%The allow this function to work properly in a parallel loop changes have
%Prototype of the function : fingerprint = fingerprintFromSelectedFrames(videoPath, selectedFrames, videoParams)

function fingerprint = fingerprintFromSelectedFrames(videoPath, selectedFrames, videoParams)

RP = getFingerprint(videoPath,selectedFrames, videoParams);
RP = rgb2gray1(RP);
sigmaRP = std2(RP);
fingerprint = WienerInDFT(RP,sigmaRP);
%Rotatating the computated fingeprint for it to be oriented in landscape
rotArg = getRotationArg(videoPath);
if rotArg > 0
    fingerprint = rot90(fingerprint,rotArg);
end

end








