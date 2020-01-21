%function returning the pce value
%receives as arguments the fingerprint and the noise 
%the value of the detected peack and the full structure are returned

function [pcePeak, pceStruct] = computePcePeak(fingerprint, noise)
       
        Cx = crosscorr(noise, fingerprint);
        detectionx = PCE(Cx);
        pcePeak = detectionx.PCE;
        pceStruct = detectionx;


end

