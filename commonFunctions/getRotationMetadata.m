%Function reading the input's video rotation parameter

function rotationMetadata = getRotationMetadata(videoFile)

%code added to read the video's h264 profile%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
commandText = strcat('ffprobe -i ',[' ' videoFile]);%,' > ',[' ' videoFile(1:length(videoFile)-4)],'_', 'videoInfos.txt');
textFile = strcat(videoFile(1:length(videoFile)-4),'_', 'videoInfos.txt');
diary(textFile);
system(commandText);%launching the ffprobe command
diary off;
clc;
rotationMetadata = 0;
%looking for the tag profile in the output file
fid = fopen(textFile);
tline = fgetl(fid);
while ischar(tline)
  if length(strfind(tline,'rotate')) > 0
     rotationMetadata = str2num(tline(length(tline)-2:length(tline)));
     break; %breaking the loop when we find the first occurence of profile
  end
  tline = fgetl(fid);
end
fclose(fid);%closing and deleting the temporary text file
delete(textFile);
end
