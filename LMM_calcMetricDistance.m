function measurementData  = LMM_calcMetricDistance(detectionData,imgProps,setParameters,dirList)
    
    outDir = setParameters.outDir;
    outDirScanline = dirList.scanline; % OutDir1
    outDirRulerOverlay = dirList.rulerOverlay; % OutDir2


    %TYPE = "gray" % gray or mid;
    %COLOR = "NA" % "white", "black", "NA";
    TYPE = "mid" ;% gray or mid;
    COLOR = "black" ;% "white", "black", "NA";


%     imgFiles = dir(char(Directory));
%     imgFiles = imgFiles(~ismember({imgFiles.name},{'.','..'}));
%     fLen = length(imgFiles);
%     fLen = string(fLen);

    % Detected images are stored in: detectionData.cropped_ ...
    % Detected properties are stored in: detectionData.detect_ ...
    imgRulers = detectionData.cropped_Ruler;
    imgRulersText = detectionData.cropped_Ruler_Text;
    dataRulers = detectionData.detect_Ruler;
    
    imgTexts = detectionData.cropped_Text;
    imgTextsText = detectionData.cropped_Text_Text;
    dataTexts = detectionData.detect_Text;
    
    % setParameters.measureText == false generally
    
    % Start with looking at the "Ruler"s
    if ~isempty(imgRulers)
        dataTicks_Ruler = LMM_findTickMarks(imgRulers,imgRulersText,dataRulers,imgProps,setParameters,dirList);
        
        
        
    end
    
    % Go through text only if user wants it
    if setParameters.measureText
        if ~isempty(imgTexts)
            %dataTicks_Text = LMM_findTickMarks(imgTexts,imgTextsText,dataTexts,imgProps,setParameters,dirList);


        end
        
    else 
        dataTicks_Text = [];
    end

    cleanedTable = LMM_cleanupImageData(imgProps, dirList, setParameters, dataTicks_Ruler,dataTicks_Text);
    
    
    
    
    
    
    measurementData.rulers = dataTicks_Ruler;
    measurementData.text = dataTicks_Text;
    
    

%     distHeaders = {'name','scan','method','yPosition','w_var','variance','n_peaks','dist_mean','dist_har','dist_geo'};
%     LOWEST = cell(0,length(distHeaders));
%     LOWEST = cell2table(LOWEST);
%     LOWEST.Properties.VariableNames = distHeaders;
% 
%     distHeaders2 = {'name','pass','method','calculated_dist','w_var'};
%     distSummary = cell(0,length(distHeaders2));
%     distSummary = cell2table(distSummary);
%     distSummary.Properties.VariableNames = distHeaders2;
% 
%     distHeadersCF = {'name','scan','method','yPosition','w_var','ConvFactor_mm','ConvFactor_imp','imp_unit'};
%     distDataCF = cell(0,length(distHeadersCF));
%     ConvFactor = cell2table(distDataCF);
%     ConvFactor.Properties.VariableNames = distHeadersCF;
% 
%     for file = imgFiles'
        %img0 = char(imgFiles(1).name);
%         img0 = char(file.name);
%         filename = strsplit(string(img0),".");
%         filename = char(filename{1})
%         filenameRead = [Directory,string(img0)];
%         filenameRead = strjoin(filenameRead,"\");
%         imgIN = imread(filenameRead);

%         % Ruler Rotation 
%         [img,imgGS,imgBW,imgBW_1pass,imgBW_2pass] = correctRulerAngle_Preprocess(imgIN,TYPE,COLOR); % binOpt == ( "gray" || "mid" ), colorOpt == ( "white" || "black" || "NA")
%     %     imgName = strcat(OutDir,filename,'_ROTATED','.jpg');
%     %     imwrite(img,imgName);

        %imshow(img)
        

%     end
%     writetable(ConvFactor,strcat(outDir,"ConvFactor",".xlsx"))
%     writetable(distSummary,strcat(outDir,"distSummary",".xlsx"))

end