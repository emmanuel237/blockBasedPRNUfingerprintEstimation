%function unloading a video previously loaded to the hard disk
%the function just delete the extracted png files in the specified folder
%the input to the function is the path to the video 
%the funtion does not return any value

function  unloadVideoFromDisk( videoPath )
%construction the string for the path of the frames images
framesPath = videoPath(1:length(videoPath)-4);
framesPath = strcat(framesPath,'Frames');
framesPath = [' ' framesPath];%adding a space to build correct command

system(strcat('rm -R',framesPath));

end

