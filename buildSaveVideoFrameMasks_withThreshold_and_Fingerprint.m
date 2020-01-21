%Function building and saving video frame masks
%uses a computing cluster to perform computation in parallel
%This is the latest version of video frameBuilder.
%usage : function [success] = buildSaveVideoFrameMasks(videoPath, outputFilePath,computingCluster,nberSlaves,framesChunckSize)
function buildSaveVideoFrameMasks_withThreshold_and_Fingerprint(videoPath, outputFilePath,nberSlaves,framesChunckSize,threshold,localVideoPath)


if isdeployed

    setmcruserdata('ParallelProfile', 'local.settings')
    %converting the input string to numerical values
    defaultProfile = parallel.defaultClusterProfile;
    computingCluster = parcluster(defaultProfile);
    saveProfile(computingCluster);
    framesChunckSize = str2num(framesChunckSize);
    threshold = str2num(threshold);    
    nberSlaves = str2num(nberSlaves);
end

if nargin > 5
    %copy the input video localy
    system(strcat('cp', [' ' videoPath ' ' localVideoPath]));
    slashPos = strfind(videoPath,'/');
    videoPath = strcat(localVideoPath,'/',videoPath(slashPos(end)+1:end));
end

%reading video properties
videoParams  = videoInfos(videoPath);
%some video resolutions are not multiple of 16 for that case the encoded
%video is bigger than the displayed one
if videoParams.height == 720
    videoHeight = 720;
    videoWidth = 1280;
else   
    if videoParams.height == 1080
        videoHeight = 1088;%size of a 1080p video in the encoded file
        videoWidth = 1920;        
    else
      videoHeight = videoParams.height;
      videoWidth = videoParams.width;
    end
end
%%%%%%% Getting the local computing cluster which should have at least 7
%%%%%%% cores
if computingCluster.NumWorkers < nberSlaves + 1
    fprintf('Not enought workers on the computing cluters, the minimum should be %d\n',nberSlaves + 1);
    success = 0;
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

videoFileName = videoPath(1:length(videoPath)-4);%Extracting the path and the name of the input video file without extension
%converting the input video to annexb H.264 format
commandText = strcat('ffmpeg -i',[' ' videoPath], ' -vcodec copy -bsf h264_mp4toannexb -an -f h264',[' ' videoFileName],'.264');
system(commandText);
%decoding the input video using ldecod in the jm reference decoder
commandText = strcat('./ldecod/./ldecod.exe -i',[' ' videoFileName], '.264 -o',[' ' videoFileName],'.yuv -xmltrace',[' ' videoFileName] ,'.xml');
system(commandText);
%%%%%% Use the displayOrder xmlfile to determine the where to place the MB
%%%%%% masks
try
displayOrderXml = xmlread(strcat(videoFileName,'_displayorder.xml'));
catch
fprintf('could not open the diplay order xml file \n');
success = 0;
return;
end
%decoding xml file opened successfullybuildSaveVideoFrameMasks_and_Fingerprint
pictureElements = displayOrderXml.getElementsByTagName('Picture');
nberFrames = pictureElements.getLength;%Number of frames in the video
%allocating memory for elements which are to be used
frameId2dispNr = zeros(nberFrames,1,'uint32');%frame Id to display order LUT used to place the mask at the correct location in the mask arrays
concealedFrames =  zeros(nberFrames,1,'uint8');% frame concealed flag 
videoFrameMasks = zeros(videoParams.height,videoParams.width,nberFrames,'uint8');

%Building the display order LUT table
for i = 0 : nberFrames - 1
   currPictureItem = pictureElements.item(i);
   displaynr = str2num(currPictureItem.getAttribute('displaynr'));
   pictureId = str2num(currPictureItem.getAttribute('id'));
   concealed = str2num(currPictureItem.getAttribute('concealed'));   
   concealedFrames(pictureId + 1) = concealed;
   frameId2dispNr(pictureId + 1) = displaynr +1 ;%shifting the frame indices of one to be in conformity with ffmpeg and matlab
    
end
%%%% checking that all the frame have been decoded successfully
if sum(concealedFrames) > 0
    fprintf('Errors occured while reading the input video\n');
    system(strcat('rm',[' ' videoFileName],'.264'));
    system(strcat('rm',[' ' videoFileName],'.yuv'));
    system(strcat('rm',[' ' videoFileName],'.xml'));
    system(strcat('rm',[' ' videoFileName,'_displayorder.xml']));
    success = 0;
    return;
end

%opening the xml trace file
xmlFileId = fopen(strcat(videoFileName,'.xml'));
if xmlFileId == -1 
    fprintf('Not decoding trace log file \n');
    success = 0;
    return;
end

%%%%%% Number of loops on parallel workers
nberLoops = floor(nberFrames/(framesChunckSize*nberSlaves));
nberRemainingFrames = nberFrames - nberLoops*framesChunckSize*nberSlaves;
%the processing are pipelined, one part is xml file reading and the second
%is mask building
%First input of the pipeline
for k = 1 : nberSlaves
    xmlFileName1{k} = strcat(videoFileName,'Chunck', num2str(k),'Stage1.xml');
    extractFramesTraceLog(xmlFileId,framesChunckSize, xmlFileName1{k})
end
%Creating and adding tasks to the job
clusterJob = createJob(computingCluster);
%subimiting the first jobs 
for k = 1 : nberSlaves
    %Adding tasks to the current job
    createTask(clusterJob,@buildPictureMasks,2,{xmlFileName1{k}, videoHeight,videoWidth});
end
%submiting the created tasks to start them meanwhile the next frame chuncks
%are being prepared
submit(clusterJob);
processedLoops = 0;
while 1 == 1  %processing the remaining loops in the pipeline
 if processedLoops < nberLoops - 1
    %Creating new xml chunk files
    for k = 1 : nberSlaves
        xmlFileName2{k} = strcat(videoFileName,'Chunck', num2str(k),'Stage2.xml');
        extractFramesTraceLog(xmlFileId,framesChunckSize, xmlFileName2{k})
    end
end
    %Waitting for the submitted tasks' completion
    wait(clusterJob);
    %Fetching the results
    computeResults = fetchOutputs(clusterJob);
    frameMasks = zeros(videoHeight, videoWidth, framesChunckSize*nberSlaves,'uint8');
    frameIndices = zeros(framesChunckSize*nberSlaves,1);
    for c = 1 : nberSlaves
        frameMasksTemp = computeResults{c,1};
        frameIdsTemp = computeResults{c,2};
        frameMasks(:,:,(c-1)*framesChunckSize + 1 :(c-1)*framesChunckSize + framesChunckSize) = uint8(frameMasksTemp);
        frameIndices((c-1)*framesChunckSize + 1 :(c-1)*framesChunckSize + framesChunckSize) = frameId2dispNr(int32(frameIdsTemp));
    end

    frameMasks = frameMasks(1:videoParams.height,1:videoParams.width,1:end);%resizing frame masks
    videoFrameMasks(:,:,frameIndices) = frameMasks(:,:,1:end);    
   %deleting temp files
    for k = 1 : nberSlaves
       system(strcat('rm', [' ' xmlFileName1{k}])); 
    end
    processedLoops = processedLoops + 1;
    %fprintf('Number of processed Loops : %d\n',processedLoops);
    if processedLoops == nberLoops
       break; %stopping the pipeline if we have done all the loops 
    end
    %submitting new tasks
    clusterJob = createJob(computingCluster);
    for k = 1 : nberSlaves
      createTask(clusterJob,@buildPictureMasks,2,{xmlFileName2{k}, videoHeight,videoWidth});
    end
    submit(clusterJob);
if processedLoops < nberLoops - 1
    %creating new chunck files
    for k = 1 : nberSlaves
        xmlFileName1{k} = strcat(videoFileName,'Chunck', num2str(k),'Stage1.xml');
        extractFramesTraceLog(xmlFileId,framesChunckSize, xmlFileName1{k})
    end
end
    %Waitting for the submitted tasks' completion
    wait(clusterJob);
    %Fetching the results
    computeResults = fetchOutputs(clusterJob);
    frameMasks = zeros(videoHeight, videoWidth, framesChunckSize*nberSlaves,'uint8');
    frameIndices = zeros(framesChunckSize*nberSlaves,1);
    for c = 1 : nberSlaves
        frameMasksTemp = computeResults{c,1};
        frameIdsTemp = computeResults{c,2};
        frameMasks(:,:,(c-1)*framesChunckSize + 1 :(c-1)*framesChunckSize + framesChunckSize) = uint8(frameMasksTemp);
        frameIndices((c-1)*framesChunckSize + 1 :(c-1)*framesChunckSize + framesChunckSize) = frameId2dispNr(int32(frameIdsTemp));
    end
    %computing the partial sums of the fingerprint termsframeMasks
    frameMasks = frameMasks(1:videoParams.height,1:videoParams.width,1:end);%resizing frame masks
    videoFrameMasks(:,:,frameIndices) = frameMasks(:,:,1:end);
    %deleting temp files
    for k = 1 : nberSlaves
       system(strcat('rm', [' ' xmlFileName2{k}])); 
    end
    processedLoops = processedLoops + 1;
    %fprintf('Number of processed Loops : %d\n',processedLoops);
    if processedLoops == nberLoops
       break; %stopping the pipeline if we have done all the loops 
    end    
    %submitting new tasks
    clusterJob = createJob(computingCluster);
    for k = 1 : nberSlaves
      createTask(clusterJob,@buildPictureMasks,2,{xmlFileName1{k}, videoHeight,videoWidth});
    end
    submit(clusterJob);
    
end

%%% computing the remaining chunks
nberRemainingChunks = floor(nberRemainingFrames/framesChunckSize);
nberRemainingFrames2 = nberRemainingFrames - nberRemainingChunks*framesChunckSize;

%processing the chunks in parallel if they exist
if nberRemainingChunks > 0
    for k = 1 : nberRemainingChunks
        xmlFileName1{k} = strcat(videoFileName,'Chunck', num2str(k),'Stage1.xml');
        extractFramesTraceLog(xmlFileId,framesChunckSize, xmlFileName1{k})
    end
    %submitting jobs
    clusterJob = createJob(computingCluster);
    for k = 1 : nberRemainingChunks
      createTask(clusterJob,@buildPictureMasks,2,{xmlFileName1{k}, videoHeight,videoWidth});
    end
    submit(clusterJob);
    wait(clusterJob);
    %Fetching the results
    computeResults = fetchOutputs(clusterJob);
    frameMasks = zeros(videoHeight, videoWidth, framesChunckSize*nberRemainingChunks,'uint8');
    frameIndices = zeros(framesChunckSize*nberRemainingChunks,1);
    for c = 1 : nberRemainingChunks
        frameMasksTemp = computeResults{c,1};
        frameIdsTemp = computeResults{c,2};
        frameMasks(:,:,(c-1)*framesChunckSize + 1 :(c-1)*framesChunckSize + framesChunckSize) = uint8(frameMasksTemp);
        frameIndices((c-1)*framesChunckSize + 1 :(c-1)*framesChunckSize + framesChunckSize) = frameId2dispNr(int32(frameIdsTemp));
    end
    frameMasks = frameMasks(1:videoParams.height,1:videoParams.width,1:end);%resizing frame masks
    videoFrameMasks(:,:,frameIndices) = frameMasks(:,:,1:end);
    %deleting temp files
    for k = 1 : nberRemainingChunks
       system(strcat('rm', [' ' xmlFileName1{k}])); 
    end
    
end
%Processing remaining frames is there isframeMasks
if nberRemainingFrames2 > 0
    xmlFileName1{1} = strcat(videoFileName,'Chunck', num2str(1),'Stage1.xml');
    extractFramesTraceLog(xmlFileId,nberRemainingFrames2, xmlFileName1{1});    
    [remainingFramesMask, remainingFramesId] = buildPictureMasks(xmlFileName1{1},videoHeight, videoWidth);
    frameMasks = remainingFramesMask;
    frameIndices = frameId2dispNr(remainingFramesId);
    frameMasks = frameMasks(1:videoParams.height,1:videoParams.width,1:end);%resizing frame masks
    videoFrameMasks(:,:,frameIndices) = frameMasks(:,:,1:end);
    %deleting temporary files
    system(strcat('rm', [' ' xmlFileName1{1}]));
end

frameIndices_all = 1:videoParams.nbFrames;
frameIndices_I = find(videoParams.framesType =='I');
frameIndices_other = find(videoParams.framesType ~='I');
loadVideoToDisk(videoPath);
fingerprint_for_all_frames = computeFingerprintBlockBased_withThreshold(videoPath,frameIndices_all,videoFrameMasks,videoParams,threshold);
fingerprint_for_I_frames = computeFingerprintBlockBased_withThreshold(videoPath,frameIndices_I,videoFrameMasks,videoParams,threshold);
fingerprint_for_other_frames = computeFingerprintBlockBased_withThreshold(videoPath,frameIndices_other,videoFrameMasks,videoParams,threshold);

videoFingerprintsFrameBased = computeFingerprints(videoPath);

unloadVideoFromDisk(videoPath);

%%%%%%%%%% Saving the video frame masks in the output file %%%%%%%%%%%%%%%
save(outputFilePath, 'videoFrameMasks', 'fingerprint_for_all_frames', ...
    'fingerprint_for_I_frames', 'fingerprint_for_other_frames', 'frameIndices_all', 'frameIndices_I', 'frameIndices_other', 'videoParams', 'videoFingerprintsFrameBased', '-v7.3');

%deleting temporary files
system(strcat('rm',[' ' videoFileName],'.264'));
system(strcat('rm',[' ' videoFileName],'.yuv'));
system(strcat('rm',[' ' videoFileName],'.xml'));
system(strcat('rm',[' ' videoFileName,'_displayorder.xml']));
if nargin > 5
    system(strcat('rm', [' ' videoPath]));
end
success = 1;

end

