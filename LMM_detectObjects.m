function detectionData = LMM_detectObjects(net,imgProps,imgText,setParameters,dirCrop)
    % Unpack
    img = imgProps.img;
    filename = imgProps.filename;
    outDir = setParameters.outDir;
    printSummary = setParameters.printSummary;
    printCropped = setParameters.printCropped;
    detectStrength = setParameters.detectStrength;
    enlarge = setParameters.enlarge;
    megapixels = imgProps.megapixels; 


    labels_all = cellstr(net.ClassNames);
    
    % Define label sets
    labels_barcode = "barcode";
    labels_text = "text";
    labels_ruler = ["blocks","blocksAndTicks","kodak","ticksBlack","ticksBlackBGgray","ticksWhite","tiffen"];
    labels_color = ["tiffenGrayScale","kodakGrayScale","colorBlock"];
    labels_unitsMetric = ["unitCM","unitMM","unitMetric"];
    labels_unitsImp = ["unit8ths","unitINCH"];
    
    % For UNIX compatibility
    if isunix, SYM = "/"; else, SYM = "\"; end    
    if megapixels < 12, LW = 3; elseif (12 <= megapixels)&&(megapixels < 20), LW = 6; else, LW = 14; end 

    % Set detection threshold
    if detectStrength == "Broad", T = 0.05;%[0.5,0.25,0.15,0.10,0.05];
    elseif detectStrength == "Strict", T = 0.25;%[0.8,0.5];
    else, T = 0.10;%[0.5,0.25,0.15,0.10];% "Avg" 
    end
    
    %%%%% DETECTION %%%%%
    detectSuccess = true;
    [bboxes, scores, labels] = detect(net,img,'ExecutionEnvironment',setParameters.useSemSeg_gpu,'Threshold',T); 
    nScores = length(scores);
    
    % Analyze BBoxes
    labelsFound = cellstr(labels);
    nLabels = length(labels);
    labelsFoundUniq = unique(labelsFound);
    
    % Return boolean for each labels type
    hasBarcode = ~isempty(labelsFoundUniq(ismember(labelsFoundUniq, labels_barcode)));
    hasColor = ~isempty(labelsFoundUniq(ismember(labelsFoundUniq, labels_color)));
    hasText = ~isempty(labelsFoundUniq(ismember(labelsFoundUniq, labels_text)));
    hasRuler = ~isempty(labelsFoundUniq(ismember(labelsFoundUniq, labels_ruler)));
    hasImp = ~isempty(labelsFoundUniq(ismember(labelsFoundUniq, labels_unitsImp)));
    hasMetric = ~isempty(labelsFoundUniq(ismember(labelsFoundUniq, labels_unitsMetric)));
    

    % If no detection, quit, skip image
    if nScores == 0
        detectSuccess = false;
        detectionData.detectSuccess = detectSuccess;
    else
        detectSuccess = true;
        summaryImg = img;
        %%%%% SORTING OUTPUT %%%%%

        %%%%% BARCODE %%%%%
        if hasBarcode
            category = "barcode";
            [summaryImg,detect_Barcode] = LMM_cleanUpBBoxes(labelsFound,labels_barcode,bboxes,scores,labels,summaryImg,enlarge,category,LW,false); 
            [cropped_Barcode, cropped_Barcode_Text] = LMM_cropImgToBBoxes(img,imgText,filename,detect_Barcode,printCropped,dirCrop,category);
            category = [];
        end    

        %%%%% COLORBLOCKS %%%%%
        if hasColor
            category = "color";
            [summaryImg,detect_Color] = LMM_cleanUpBBoxes(labelsFound,labels_color,bboxes,scores,labels,summaryImg,enlarge,category,LW,false); 
            [cropped_Color, cropped_Color_Text] = LMM_cropImgToBBoxes(img,imgText,filename,detect_Color,printCropped,dirCrop,category);
            category = [];
        end

        %%%%% TEXT %%%%%
        if hasText
            category = "text";
            [summaryImg,detect_Text] = LMM_cleanUpBBoxes(labelsFound,labels_text,bboxes,scores,labels,summaryImg,enlarge,category,LW,false); 
            [cropped_Text, cropped_Text_Text] = LMM_cropImgToBBoxes(img,imgText,filename,detect_Text,printCropped,dirCrop,category);
            category = [];
        end 

        %%%%% RULERS %%%%%
        if hasRuler
            category = "ruler";
            [summaryImg,detect_Ruler] = LMM_cleanUpBBoxes(labelsFound,labels_ruler,bboxes,scores,labels,summaryImg,enlarge,category,LW,false); 
            [cropped_Ruler, cropped_Ruler_Text] = LMM_cropImgToBBoxes(img,imgText,filename,detect_Ruler,printCropped,dirCrop,category);
            category = [];
        end

        %%%%% IMPERIAL UNITS %%%%%
        if hasImp
            category = "unitImp";
            [summaryImg,detect_UnitsImp] = LMM_cleanUpBBoxes(labelsFound,labels_unitsImp,bboxes,scores,labels,summaryImg,enlarge,category,LW,false);
            [cropped_UnitsImp, cropped_UnitsImp_Text] = LMM_cropImgToBBoxes(img,imgText,filename,detect_UnitsImp,printCropped,dirCrop,category);
            category = [];
        end

        %%%%% METRIC UNITS %%%%%
        if hasMetric
            category = "unitMetric";
            [summaryImg,detect_UnitsMetric] = LMM_cleanUpBBoxes(labelsFound,labels_unitsMetric,bboxes,scores,labels,summaryImg,enlarge,category,LW,false); 
            [cropped_UnitsMetric, cropped_UnitsMetric_Text] = LMM_cropImgToBBoxes(img,imgText,filename,detect_UnitsMetric,printCropped,dirCrop,category);
            category = [];
        end
        
        %%%%% PRINT SUMMARY IMAGE %%%%%
        if printSummary
            name3 = strcat(outDir,SYM,"Summary",SYM,filename,"_Objects.jpg");
            imwrite(summaryImg,name3) 
        end  
        
        % Save output data
        detectionData.detectSuccess = detectSuccess;
        detectionData.summaryImg = summaryImg;
        
        if hasBarcode
        detectionData.detect_Barcode = detect_Barcode;
        detectionData.cropped_Barcode = cropped_Barcode;
        detectionData.cropped_Barcode_Text = cropped_Barcode_Text;
        else
        detectionData.detect_Barcode = [];
        detectionData.cropped_Barcode = [];
        detectionData.cropped_Barcode_Text = [];
        end
        
        if hasColor
        detectionData.detect_Color = detect_Color;
        detectionData.cropped_Color = cropped_Color;
        detectionData.cropped_Color_Text = cropped_Color_Text;
        else
        detectionData.detect_Color = [];
        detectionData.cropped_Color = [];
        detectionData.cropped_Color_Text = [];
        end
        
        if hasText
        detectionData.detect_Text = detect_Text;
        detectionData.cropped_Text = cropped_Text;
        detectionData.cropped_Text_Text = cropped_Text_Text;
        else
        detectionData.detect_Text = [];
        detectionData.cropped_Text = [];
        detectionData.cropped_Text_Text = [];
        end
        
        if hasRuler
        detectionData.detect_Ruler = detect_Ruler;
        detectionData.cropped_Ruler = cropped_Ruler;
        detectionData.cropped_Ruler_Text = cropped_Ruler_Text;
        else
        detectionData.detect_Ruler = [];
        detectionData.cropped_Ruler = [];
        detectionData.cropped_Ruler_Text = [];
        end
        
        if hasImp
        detectionData.detect_UnitsImp = detect_UnitsImp;
        detectionData.cropped_UnitsImp = cropped_UnitsImp;
        detectionData.cropped_UnitsImp_Text = cropped_UnitsImp_Text;
        else
        detectionData.detect_UnitsImp = [];
        detectionData.cropped_UnitsImp = [];
        detectionData.cropped_UnitsImp_Text = [];
        end
        
        if hasMetric
        detectionData.detect_UnitsMetric = detect_UnitsMetric;
        detectionData.cropped_UnitsMetric = cropped_UnitsMetric;
        detectionData.cropped_UnitsMetric_Text = cropped_UnitsMetric_Text;
        else
        detectionData.detect_UnitsMetric = [];
        detectionData.cropped_UnitsMetric = [];
        detectionData.cropped_UnitsMetric_Text = [];
        end
    end  
end