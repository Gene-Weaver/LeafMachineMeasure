% Run semantic segmentation from LeafMachine
% Obtain the "text" class, crop down this image base on 
% BBOX prediction from the YOLO object detector


function textFromImage = LMM_basicSegmentation(net,image,cpu_gpu)

    % Segmentation
    [C,~,~] = semanticseg(image,net,'ExecutionEnvironment',cpu_gpu);
    
    binaryMasks = LMM_getBinaryMasks(C);
    
    com = imcomplement(binaryMasks.text);
    
    textFromImage = bsxfun(@times, image, cast(binaryMasks.text, 'like', image));
    
    textFromImage2 = textFromImage;
    
    M = repmat(all(~textFromImage,3),[1 1 3]); %mask black parts
    textFromImage(M) = 255;
    
    
    %textFromImage = binaryMasks.text;

    %B = labeloverlay(image,C);
    
end