%funtion reading a video file and writing all the frames in a folder having
%the same name wiht the input video file
%the function uses ffmpeg to decode frames and extract them as lossless .bmp
%files in subfolders named Iframes and PBframes located in a folder
%having the video's file name (without extension) 
%the input file is the path to the input video and the returned value is
%the function returns the parameters returned by the funtion videoInfos
%namely : 
%-the file path (fileName)
%-video's width and height
%-number of frames 
%- ... etc see videoInfos
%the function writes in a log file to mark that errors occured during frames
%reading if it finds a frame which could not be read.

function videoProperties = loadVideoToDisk(videoPath)
%extracting the video file name and creating the folder where the files
%will be stored
videoProperties = videoInfos(videoPath);
%slashPos = strfind(videoPath,'/');
errorMsg = ''; %error message written in the log file is errors occur during frames reading
framesPath = videoPath(1:length(videoPath)-4);%removing the extention from the video's name
framesPath = strcat(framesPath,'Frames');
framesPath = [' ' framesPath];%adding a space to build correct command
%command to create folder that will hold the subfolders that will containg the frames
commandText = strcat('mkdir', framesPath);
system(commandText);
%creating the subfolder for Iframes
commandText = strcat('cd', framesPath);
system(commandText);
IframesFolder = ' Iframes';
PBframesFolder = ' PBframes';
commandText = strcat('mkdir', framesPath,'/','Iframes');
system(commandText);

commandText = strcat('mkdir', framesPath,'/','PBframes');
system(commandText);

%building the command for ffmpeg
videoPath = [' ' videoPath];
%extracting the I frames in the folder Iframes
commandText = strcat('ffmpeg -i ',videoPath,' -vf "select=eq(pict_type\,I)" -vsync vfr', framesPath,'/','Iframes','/Iframe%d.bmp');
system(commandText); %extracting frames 
%counting the number of frames extracted which corresponds to the number of files
%in the folder
framesFileNames = '';
fileNames = dir(strcat(framesPath(2:length(framesPath)),'/Iframes'));
fileNames = fileNames(3:length(fileNames)); %removing the . and .. in the file names
nberIimages = length(fileNames);
if videoProperties.nbIframes ~= nberIimages
    videoProperties.nbIframes = nberIimages;
    %'/!\ couldnt read all I frames'
    errorMsg = strcat(errorMsg, 'Could not read all the I frames from the video');
end
%concatenating the files names for futher checks
for i = 1 : nberIimages
    framesFileNames = strcat(framesFileNames,fileNames(i).name);
end

%extracting the P frames in the folder PBframes
commandText = strcat('ffmpeg -i ',videoPath,' -vf "select=eq(pict_type\,P)" -vsync vfr', framesPath,'/','PBframes','/Pframe%d.bmp');
system(commandText); %extracting frames 
%counting the number of frames extracted which corresponds to the number of files
%in the folder
fileNames = dir(strcat(framesPath(2:length(framesPath)),'/PBframes'));
fileNames = fileNames(3:length(fileNames));
nberPimages = length(fileNames);
if videoProperties.nbPframes ~= nberPimages
    videoProperties.nbPframes = nberPimages;
    %'/!\ couldnt read all the P frames'
    errorMsg = strcat(errorMsg, 'Could not read all the P frames from the video');
end

for i = 1 : nberPimages
    framesFileNames = strcat(framesFileNames,fileNames(i).name);
end

%extracting the B frames in the folder PBframes
commandText = strcat('ffmpeg -i ',videoPath,' -vf "select=eq(pict_type\,B)" -vsync vfr', framesPath,'/','PBframes','/Bframe%d.bmp');
system(commandText); %extracting frames 
%counting the number of frames extracted which corresponds to the number of files
%in the folder
fileNames = dir(strcat(framesPath(2:length(framesPath)),'/PBframes'));
fileNames = fileNames(3:length(fileNames));
nberBimages = length(fileNames);
nberBimages = nberBimages - nberPimages;
if videoProperties.nbBframes ~= nberBimages
    videoProperties.nbBframes = nberBimages;
    %'/!\ couldnt read all the B frames'
    errorMsg = strcat(errorMsg, 'Could not read all the B frames from the video');
end
for i = 1 : nberBimages
    framesFileNames = strcat(framesFileNames,fileNames(i).name);
end
%checking the extracted files because the decoder can fail to extract some
%frames.
%this part of the script will check that the frames are really extracted and
%will stop as soon as it meets a frame which could not be extracted
for i = 1: length(videoProperties.framesType)
   frameImageName = getFrameImageFileName(i,videoProperties);
   testFile = length(strfind(framesFileNames,frameImageName));
   if testFile == 0 %if the corresponding file doesn't exist stop browsing and return the correct chunck
     videoProperties.framesType = videoProperties.framesType(1:i-1);  
     videoProperties.nbFrames = i-1;
     break;
   end
    
end
%creating a log file if errors has occured during frames reading
if length(errorMsg) > 0
   '/!\Errors occured during reading; saving a log file/!\'
   fileId = fopen(strcat(framesPath(2:length(framesPath)),'readLog.txt'),'w');
   fprintf(fileId,'%s\n',errorMsg);
   fclose(fileId);
end


end














