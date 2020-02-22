## usage:
buildSaveVideoFrameMasks_withThreshold_and_Fingerprint(videoPath,outputFilePath,nberSlaves,framesChunckSize,threshold,localVideoPath)
# Input parameters:
1.videoPath : the input video
2.outputFilePath : the full path to the file where the results will be stored (a .mat file)
3.nberSlaves : the number of cores that will be used for processing (this represents the number of PHYSICAL cores, so if your processor uses hyperthreading you have to divide the number of cores seen by the OS by two. There should be an extra core which is used as master in our parallelization algorithm). For example, the computer I used to run this command has an Intel(R) Core(TM) i7-8700K  processor which has 6 physical cores (but with hyperthreading it is seen as a 12 cored processor by the OS). This is why this parameter is 5 (in short this parameter's value should be number_of_physical_core -1)
4.frameChuckSize: keeping this value between 8 and 10 and it will be fine.
5.threshold: represents the threshold of non-nul DCT-AC coefficients that will be used for block selection. The results presented in the paper are obtained with a thresold value of 1.
6.localVideoPath (optional) can be used to set a temporary working folder
# Return values:
The results of the processing are available in the output file. The output file is a .mat file that contains the following variables: 
-fingerprint_for_all_frames : the fingeprint computed using all frames.
-fingerprint_for_I_frames : the fingeprint computed using only I frames.
-fingerprint_for_other_frames : the fingeprint computed using all the frames in the video except I frames.
-videoFrameMasks : this variable contains for each 4x4 blocks the number of non-null DCT-AC coefficients (you normally don't have to use it).

