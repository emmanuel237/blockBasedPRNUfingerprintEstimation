function  generateComputeScript(deviceFolder,deviceSubFolders,sharedResultsFolder,scriptFileName)
%the program browses the folder and subfolder and generate a compute script
%for all the video related to the device


fid = fopen(scriptFileName,'w');
fprintf(fid,'#!/bin/bash\n');


for n = 1 : length(deviceSubFolders)
    %subfolder in the main folder
    
    videoFiles = dir(strcat(deviceFolder,'/',deviceSubFolders{n},'/*.mp4'));
    if length(videoFiles) == 0
        videoFiles = dir(strcat(deviceFolder,'/',deviceSubFolders{n},'/*.mov'));
        
        if length(videoFiles) == 0
            videoFiles = dir(strcat(deviceFolder,'/',deviceSubFolders{n},'/.*3gp'));
            
        end
    end
    
    if length(videoFiles)== 0
        fprintf('No video file in the selected directory\n')
        return
    else
        
        %creating the ouput file
        slashPos = strfind(deviceFolder,'/');
        outFolder = strcat(sharedResultsFolder,'/',deviceFolder(slashPos(end-1)+1:slashPos(end)-1),'/',deviceFolder(slashPos(end)+1:end),deviceSubFolders{n});
        
        fprintf(fid,'mkdir -p %s\n',outFolder);
        for k = 1 : length(videoFiles)
           
         computeCommand = strcat('sh run_buildSaveVideoFrameMasks_withThreshold_and_Fingerprint.sh /usr/local/MATLAB/MATLAB_Runtime/v95');
         videoDistantPath = strcat(deviceFolder,'/',deviceSubFolders{n},'/',videoFiles(k).name);
         videoLocalPath = strcat('/home/mpiuser');
         tempvidFile = videoFiles(k).name;
         outputFile = strcat(outFolder,'/',tempvidFile(1:end-4),'.mat');
         computeCommand = strcat(computeCommand, [' ' videoDistantPath, ' ' outputFile], [' ' 'fakeCluster'],[' ' '4, 8, 1'], [' ' videoLocalPath]);
         
         
         fprintf(fid,'%s\n',computeCommand);
            
        end
        
        
        
    end
    
end






end

