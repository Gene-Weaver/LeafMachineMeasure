% Crop the image to each bounding box


function [cropped, croppedText] = LMM_cropImgToBBoxes(img,imgT,name,detect,imgSave,dirCrop,category)
    bboxes = detect.bboxes;
    labels = detect.labels;
    scores = detect.scores;
    
    % Determine label category 
    %categories = ["barcode"; "color"; "text"; "ruler"; "unitImp"; "unitMetric"];
    if imgSave
        if category == "barcode", dirOut = dirCrop.barcode; end
        if category == "color", dirOut = dirCrop.color; end
        if category == "text", dirOut = dirCrop.text; end
        if category == "ruler", dirOut = dirCrop.ruler; end
        if category == "unitImp", dirOut = dirCrop.unitsImp; end
        if category == "unitMetric", dirOut = dirCrop.unitsMetric; end
    end
    
    [S1,~] = size(bboxes);
    
    cropped = cell(S1,1);
    if ~isempty(imgT), croppedText = cell(S1,1); end
    
    for i = 1:S1
        imgCrop = imcrop(img,bboxes(i,:));
        if ~isempty(imgT), imgText = imcrop(imgT,bboxes(i,:)); end
        cropped{i} = imgCrop;
        if ~isempty(imgT), croppedText{i} = imgText; end
        if imgSave
            L = string(labels(i));
            S = string(round(scores(i),4));
            S = strrep(S,'.','');
            nameOut = strcat(name,"__",L,"_",string(i),"_sc",S,".jpg");
            imwrite(imgCrop,fullfile(dirOut,nameOut));
        end
    end
    if isempty(imgT), croppedText = []; end
end