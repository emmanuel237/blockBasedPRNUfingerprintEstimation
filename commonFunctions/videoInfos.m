%function exacting informations from a give video.
%takes as input the path to the targeted video file
%@ input argument : the text file name
%@ output values : returns a structures with the following fields :
% - the input video file name (useful to browse folder of video files)
% - nbIframes : total number of I frames
% - nbPframes : total number of P frames
% - nbBframes : total number of B frames
% - nbFrames  :  number of frames in the video sequence
%fileName = strcat(videoFile(1:length(videoFile-4)),'_','frame',int2str(n),'.jpg');

function videoInfos = videoInfos(videoFile)

%code added to read the video's h264 profile%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
commandText = strcat('ffprobe -v error -show_format -show_streams',[' ' videoFile],' > ',videoFile(1:length(videoFile)-4),'_', 'videoInfos.txt');
system(commandText);%launching the ffprobe command
clc;
textFile = strcat(videoFile(1:length(videoFile)-4),'_', 'videoInfos.txt');
%looking for the tag profile in the output file
fid = fopen(textFile);
tline = fgetl(fid);
while ischar(tline)
  if length(strfind(tline,'profile')) > 0
     profile = tline(9:end); 
     break; %breaking the loop when we find the first occurence of profile
  end
  tline = fgetl(fid);
end
fclose(fid);%closing and deleting the temporary text file
delete(textFile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

commandText = strcat('ffprobe -show_frames -select_streams v:0 -show_entries stream=bit_rate',[' ' videoFile],' > ',videoFile(1:length(videoFile)-4),'_', 'videoInfos.txt');
system(commandText);
textFile = strcat(videoFile(1:length(videoFile)-4),'_', 'videoInfos.txt');
clc %clearing the console to remove messages from system command
fid = fopen(textFile);%opening the text file
tline = fgetl(fid);%reading a line in the text file
%initializing the counter variables
nbIframes = 0;
nbPframes = 0;
nbBframes = 0;
arrayIndex = 1;
GOPcount = 0;
while ischar(tline)
%looking for the begining of a frame
  if length(strfind(tline,'[FRAME]')) > 0
  %reading the info up to getting the end of frame marker
  tline = fgetl(fid);
  while length(strfind(tline,'[/FRAME]')) == 0    
  %looking for the marker pict_type
  if length(strfind(tline,'pict_type')) > 0
     framesType(arrayIndex) = tline(11);%taking the frame's type 
     %checking for the frame's type to count them
   switch framesType(arrayIndex)
       case 'I'
           nbIframes = nbIframes + 1;
           GOPstruct(arrayIndex) = 0;%GOP structure of the video
           GOPcount = GOPcount + 1 ;
       case 'P'
           nbPframes = nbPframes + 1;
           GOPstruct(arrayIndex) = GOPcount;
           
       case 'B'
           nbBframes = nbBframes + 1;
           GOPstruct(arrayIndex) = GOPcount;
     end 
   arrayIndex = arrayIndex + 1;
  end
  %extracting the width and heigth of the video file
  if length(strfind(tline,'width')) > 0
      width = str2num(tline(7:length(tline)));
  end
  
  if length(strfind(tline,'height')) > 0
      height = str2num(tline(8:length(tline)));
  end

 
  tline = fgetl(fid);
  end
 end
tline = fgetl(fid);%reading a line in the text file 
  %Extracting the bitrate of the video stream which is at the end of the
  %produced file
   if length(strfind(tline,'bit_rate')) > 0
      bitrate = round((str2num(tline(10:length(tline))))/1000);
  end
end
%computing the total number of frames in the video
nbFrames = nbIframes + nbPframes + nbBframes;
%determining the GOP size
indices = 1:1:nbFrames;
Iframes = indices(framesType == 'I');
%Determining the size of each GOP
for n = 1 : length(Iframes) -1

 GOPsize(n) = Iframes(n + 1) - Iframes(n);
 
end

%returning the results as a structure

videoInfos = struct('fileName',videoFile,'width',width,'height',height,'video_bitrate',bitrate,'profile',profile,'nbIframes', nbIframes, 'nbPframes', nbPframes, 'nbBframes', nbBframes, 'nbFrames',nbFrames, 'GOPstruct',GOPstruct, 'Gopsize',GOPsize,'framesType',framesType);

%deleting the temporary text file
delete(textFile);
end
