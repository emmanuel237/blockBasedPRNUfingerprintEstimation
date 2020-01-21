%Function extracting xml trace log of a bunch of frames.
%recieves as input argument:
%@fid: file id of the opened xml file
%@nberFrames: number of frames to process
%@outputFileName : output file name
%function  extractFramesTraceLog(Fid, nberFrames, outputFileName)
function  extractFramesTraceLog(Fid, nberFrames, outputFileName)
%Opening the output xml file
ofid = fopen(outputFileName,'w');
fprintf(ofid,'<FrameDecodeTrace> \n');
n = 0;
%line = fgetl(Fid);
while n < nberFrames
    line = fgetl(Fid);
    %looking for the <picture markup
    if length(strfind(line,'<Picture')) > 0
        fprintf(ofid,'%s\n',line);
        %writting the xml content up to the end of the record
        while 1==1
            line = fgetl(Fid);
            if length(strfind(line,'</Picture')) == 0
                %if the closing markup if not found we write the content to the xml output file
                fprintf(ofid,'%s\n',line);
            else
                %end of the frame information, we close the markup
                fprintf(ofid,'%s\n',line);
                 n = n + 1;
                break;
            end     
        end
    end
end
fprintf(ofid,'</FrameDecodeTrace> \n');
fclose(ofid);
end

