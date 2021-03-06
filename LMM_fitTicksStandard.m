function dataOut = LMM_fitTicksStandard(imgBW,imgProps,dirList,setParameters,imgSet,type,color,indObject)
%     addpath('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\')
%     %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\black_Dual__1790__1.jpg'); %white ticks, dual    %sortCheckComplete
%     %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\black_Metric__454__2.jpg'); % white ticks, single % bad
%     %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\blackSplit_Dual__1980__1.jpg'); % white ticks dual % good
%     %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\blackStrip_MM__668__2.jpg'); % white ticks, single   % good, passed the
%     %check1check2 swap
%     %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\clear_Dual__1171__2.jpg'); % black ticks, dual, both mm   % good
%     %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\clear_Dual__2152__2.jpg'); % black ticks, dual 1/2 mm and mm white_Metric__2095__2 % good
%     %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\white_Metric__2095__2.jpg'); % black ticks, single 1,1/2,1/4 cm ?!?! 
%     img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\whiteComplex10CM_Metric__1506__2.jpg'); % black ticks, mm and blocks 
%     type = "mid";
%     %color = "white";
%     color = "black";
%     imgSet = LMM_correctRulerAnglePreprocess(img,type,color);
%     imgBW = imgSet.imgBW;
%     filename = "black_Dual__1790__1";
    
    
    
    % Setup table
    distHeaders = {'name','scan','method','yPosition','w_var','variance','n_peaks','dist_mean','dist_har','dist_geo'};
    distHeaders2 = {'name','scanline','method','calculated_dist','imperialUnit','nPeaks'};
    distHeadersCF = {'name','scan','method','yPosition','w_var','ConvFactor_mm','ConvFactor_imp','imp_unit','nPeaks'};
    distDataCF = cell(0,length(distHeadersCF));
    ConvFactor = cell2table(distDataCF);
    ConvFactor.Properties.VariableNames = distHeadersCF;
    
    filename = imgProps.filename;
    
    % If looking for white ticks, swap
    numWhitePixels = sum(imgBW(:));
    numBlackPixels = sum(~imgBW(:));
    if numWhitePixels <= numBlackPixels
        imgBW = imcomplement(imgBW);
    end
    IMG_run = imgBW;
    
    % Extract Harris Features
    boxPoints = detectHarrisFeatures(IMG_run,'MinQuality', 0.15);
    [boxFeatures, boxPoints] = extractFeatures(IMG_run, boxPoints);

   
    IMG_pts = boxPoints;
    scanlineOption = [10,20,30];
    
    distData = cell(0,length(distHeaders));
    distScanlines = cell2table(distData);
    distScanlines.Properties.VariableNames = distHeaders; 
    
    distHeadersP = {'Scan','Yimg','x','y'};
    imgPOINTSData = cell(0,length(distHeadersP));
    imgPOINTS = cell2table(imgPOINTSData);
    imgPOINTS.Properties.VariableNames = distHeadersP; 
    
    for slo = 1:length(scanlineOption)%ii = 10,20,30
        distDataONEslo = cell(0,length(distHeaders));
        distScanlinesONEslo = cell2table(distDataONEslo);
        distScanlinesONEslo.Properties.VariableNames = distHeaders;
        
        ii = scanlineOption(slo);
        NAME = string(filename);
        
        
        [scanlineCropImgs,scanlineCropHpts] = LMM_scanlineCrop(IMG_run,IMG_pts,ii);
        
        for i=1:length(scanlineCropImgs)
            SCAN = strcat("scan",string(ii),"_",string(i));
            ADDpts1 = cell(1,length(distHeadersP));
            ADDpts = cell2table(ADDpts1);
            ADDpts.Properties.VariableNames = distHeadersP; 
            yPosOverall = ((ii/2)*i);
            yPosScan = ii/2;
            %[TABLE,POINTS] = fitTicks_MM_blackTicks(scanlineCropImgs{i},TYPE,scanlineCropHpts{i},IMG_pts,0,distHeaders,NAME,SCAN,yPosOverall,yPosScan);
            [TABLE,POINTS] = LMM_fitTicksMMblackTicks(scanlineCropImgs{i},type,scanlineCropHpts{i},IMG_pts,0,distHeaders,NAME,SCAN,yPosOverall,yPosScan);
            distScanlinesONEslo = [distScanlinesONEslo;TABLE];%slo = one scan line option only
            distScanlines = [distScanlines;TABLE];
            ADDpts.Yimg = yPosOverall;
            ADDpts.Scan = SCAN;
            if isempty(POINTS) 
                ADDpts.x = {0};
                ADDpts.y = {0};
            else
                ADDpts.x = {POINTS(1,:)};
                ADDpts.y = {POINTS(2,:)};
            end
            imgPOINTS = [imgPOINTS;ADDpts];
        end
    end
    % Sort only rows with more than 2 peaks, for clustering analysis in LMM_sortDistScanlines()
    distScanlinesSort = distScanlines(distScanlines.n_peaks >= 2,:);
    
    %%% Sort through th scanlines. Oh my goodness this function was a pain to code
    if height(distScanlinesSort) >= 3
        bestScanlines = LMM_sortDistScanlines(distScanlinesSort);
    else
        bestScanlines = distScanlines;
    end
    bestScanlinesTable = LMM_buildScanlinesTable(bestScanlines);
    usedTable = bestScanlinesTable(bestScanlinesTable.Selected == "Used",:);
    
    if setParameters.printScanlineMetadata
        writetable(distScanlines,fullfile(dirList.scanline,strcat(filename,"_scanlines_all",".xlsx"))) 
        writetable(bestScanlinesTable,fullfile(dirList.scanline,strcat(filename,"_scanlines_used",".xlsx"))) 
    end
    
    %%% Write image overlay
    if setParameters.printScanlineMetadata
        if height(usedTable) > 0
            plotPts = LMM_save1cmOverlay_Standard(usedTable,imgPOINTS,imgSet,imgProps,setParameters,dirList,indObject);
        else
            plotPts = [];
        end
    end
    
    

    
    %%%%%%%%%%
    % FORMAT for data out
    % Save out
    dataOut.usedTable = usedTable; % Centroid(2cols), BBox(4cols), MajorAxisLength(1col), Circularity(1col)
    dataOut.convFactorCM = [];
    dataOut.convFactorMM = [];
    dataOut.variance = [];
    dataOut.wVar = [];
    dataOut.nPeaks = [];
    dataOut.yPosition = [];
    dataOut.plotPts = plotPts;
    dataOut.method = "standard";
    dataOut.scan = bestScanlines;
    dataOut.validation = usedTable.ConversionMessage;


end
