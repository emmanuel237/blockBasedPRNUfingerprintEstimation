%Function building a frame mask based on the dct coefficients of the luma
%component.
%Recieves as input : The xml file of the decoding trace of the file,
%@currentPicture: xmlNode of the current picture
%videoHeight : the height of the video as it is in the xml file
%videoWidht : the width of the video as it is in the xml file
%frameXmFile = frameXmlFileName;
%videoHeight = videoHeight;
%videoWidth = videoWidth;
%videoProfile = videoParams.profile;
%function [frameMask, frameId] =  buildFrameMask(currentPicture,videoHeight, videoWidth)
function [frameMask, frameId] =  buildFrameMask(currentPicture,videoHeight, videoWidth)

frameId = str2num(currentPicture.getAttribute('id')) + 1;
%reading all the macroblocks in the frame
frameMacroblocks = currentPicture.getElementsByTagName('MacroBlock');
nberMacroblocks = frameMacroblocks.getLength;
frameMask = uint8(zeros(videoHeight, videoWidth));
macroblockPosition = [0 0]; % Macroblock position under the format [row col]
validBlocks = int8(zeros(4,4));%Block having DCT-AC components
for i = 0 : nberMacroblocks - 1
    
    currentMacroblock = frameMacroblocks.item(i); %getting the current element
    %%%%% reading the current Macroblock position
    macroblockPositionItems = currentMacroblock.getElementsByTagName('Position');
    macroblockPositionItem = macroblockPositionItems.item(0);
    positionItem = macroblockPositionItem.getElementsByTagName('X');
    tempItem = positionItem.item(0);
    tempChild = tempItem.getFirstChild;
    macroblockPosition(2) = str2num(char(tempChild.getData)) + 1; %macroblock x poisition
    positionItem = macroblockPositionItem.getElementsByTagName('Y');
    tempItem = positionItem.item(0);
    tempChild = tempItem.getFirstChild;
    macroblockPosition(1) = str2num(char(tempChild.getData)) + 1; %macroblock y poisition
    
    macroblockMask = uint8(zeros(16,16)); %initializing the current Macroblock mask to zeros
    coeffs = currentMacroblock.getElementsByTagName('Coeffs');
    currCoeffs = coeffs.item(0);
    %coeffPlanes = currCoeffs.getElementsByTagName('Plane');
    %LumaCoeffs = coeffPlanes.item(0);
    LumaCoeffsRows = currCoeffs.getElementsByTagName('Row');
    %reading the DCT coefficients line by line
    for k = 0 : LumaCoeffsRows.getLength -1
        row = LumaCoeffsRows.item(k);
        tempItem = row.getFirstChild;
        validBlocks(k+1,:) = str2num(char(tempItem.getData));
    end
    %building the current Macroblock mask
    for l = 1 : 4
        for c = 1 : 4
                macroblockMask((l-1)*4 + 1 : (l-1)*4 + 4, (c-1)*4 + 1 : (c-1)*4 + 4 ) = validBlocks(l,c);
        end
    end
    %copy the block mask at its location in the frame mask
    frameMask(macroblockPosition(1):macroblockPosition(1)+15,macroblockPosition(2):macroblockPosition(2)+15) = macroblockMask;
    
end


end