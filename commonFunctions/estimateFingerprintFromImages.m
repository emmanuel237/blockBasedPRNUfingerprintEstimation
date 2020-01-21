%Function estimating fingerprint from a set of images
%The images are used to estimate the fingerprint are int the folder passed
%as argument
function [fingerprint] = estimateFingerprintFromImages(imagesFolder)

imageFiles = dir(imagesFolder);
imageFiles = imageFiles(3:end);

for i=1: length(imageFiles)
images(i).name = strcat(imagesFolder,'/',imageFiles(i).name);
end

fingerprint = getFingerprint_Jessica(images);
fingerprint = rgb2gray1(fingerprint);
sigmaFp = std2(fingerprint);
fingerprint = WienerInDFT(fingerprint,sigmaFp);

end

