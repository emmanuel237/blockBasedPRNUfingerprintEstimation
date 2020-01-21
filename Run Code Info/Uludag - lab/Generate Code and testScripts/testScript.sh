#!/bin/bash
mkdir -p /resultVolume/D01_Samsung_GalaxyS3Mini/videosflatYT
sh  /run_buildSaveVideoFrameMasks_withThreshold_and_Fingerprint.sh /opt/mcr/v95 /videosDistantVolume/flatYT/D01_V_flatYT_move_0001.mp4 /resultVolume/D01_Samsung_GalaxyS3Mini/videosflatYT/D01_V_flatYT_move_0001.mat 3 8 1 /tempVolume

