%Function returning value of the argument that should be passed to rot90 in
%order to correct frame rotation applied by the acquisition device

function rotationArg = getRotationArg(videoPath)

%Getting the rotation metadata
rotationMetadata = getRotationMetadata(videoPath);
switch rotationMetadata
    
    case 0
        rotationArg = 0;
    case 90
        rotationArg = 1;
    case 180
        rotationArg = 2;
    case 270
        rotationArg = 3;
    otherwise
       rotationArg = 0; 
end
        

end