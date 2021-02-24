% Conflicted / old version, try the "pixelToMetricDistance.m" versoion first 

% Optimize for ruler type
        if type == "gray"
            imgRun = imgBW;
            numWhitePixels = sum(imgBW(:));
            numBlackPixels = sum(~imgBW(:));

            if numWhitePixels >= numBlackPixels, imgBW = imcomplement(imgBW);end

            % Extract Harris Features
            boxPoints = detectHarrisFeatures(imgRun,'MinQuality', 0.15);
            [boxFeatures, boxPoints] = extractFeatures(imgRun, boxPoints);

        else
            if color == "NA"
                imgRun = imgBW;

                % Extract Harris Features
                boxPoints = detectHarrisFeatures(imgRun,'MinQuality', 0.15);
                [boxFeatures, boxPoints] = extractFeatures(imgRun, boxPoints);
            else
                imgRun = imgBW_1pass;

                % Extract Harris Features
                boxPoints = detectHarrisFeatures(imgRun,'MinQuality', 0.15);
                [boxFeatures, boxPoints] = extractFeatures(imgRun, boxPoints);
            end
        end

        imgPts = boxPoints;
        scanlineOption = [10,20,30];

        % Setup table for scanline operations
        distHeaders = {'name','scan','method','yPosition','w_var','variance','n_peaks','dist_mean','dist_har','dist_geo'};
        distData = cell(0,length(distHeaders));
        distScanlines = cell2table(distData);
        distScanlines.Properties.VariableNames = distHeaders; 

        distHeadersCF = {'name','scan','method','yPosition','w_var','ConvFactor_mm','ConvFactor_imp','imp_unit'};
        distDataCF = cell(0,length(distHeadersCF));
        ConvFactor = cell2table(distDataCF);
        ConvFactor.Properties.VariableNames = distHeadersCF;

        distHeaders2 = {'name','pass','method','calculated_dist','w_var'};
        distSummary = cell(0,length(distHeaders2));
        distSummary = cell2table(distSummary);
        distSummary.Properties.VariableNames = distHeaders2;

        distHeadersP = {'Yimg','x','y'};
        imgPOINTSData = cell(0,length(distHeadersP));
        imgPOINTS = cell2table(imgPOINTSData);
        imgPOINTS.Properties.VariableNames = distHeadersP; 

        for slo = 1:length(scanlineOption)%ii = 10,20,30
            distDataONEslo = cell(0,length(distHeaders));
            distScanlinesONEslo = cell2table(distDataONEslo);
            distScanlinesONEslo.Properties.VariableNames = distHeaders;

            ii = scanlineOption(slo);
            NAME = strcat("img",string(filename));
            SCAN = strcat("scan",string(ii));

            % Perform scanline crop
            [scanlineCropImgs,scanlineCropHpts] = LMM_scanlineCrop(imgRun, imgPts, ii);

            for i=1:length(scanlineCropImgs)
                ADDpts1 = cell(1,length(distHeadersP));
                ADDpts = cell2table(ADDpts1);
                ADDpts.Properties.VariableNames = distHeadersP; 
                yPosOverall = ((ii/2)*i);
                yPosScan = ii/2;

                % Fit ticks
                dist = LMM_fitTicksSURFpoints(boxPoints)
                [TABLE,POINTS] = LMM_fitTicksMMblackTicks(scanlineCropImgs{i}, type, scanlineCropHpts{i} ,imgPts, 0, distHeaders, NAME, SCAN, yPosOverall, yPosScan);

                distScanlinesONEslo = [distScanlinesONEslo;TABLE];
                distScanlines = [distScanlines;TABLE];
                ADDpts.Yimg = yPosOverall;
                if isempty(POINTS) == 1
                    ADDpts.x = {NaN};
                    ADDpts.y = {NaN};
                else
                    ADDpts.x = {POINTS(1,:)};
                    ADDpts.y = {POINTS(2,:)};
                end
                imgPOINTS = [imgPOINTS;ADDpts];
            end

            min_Wvar = min(distScanlinesONEslo.w_var(distScanlinesONEslo.w_var>0));

            %%% METHOD TO FIND CM AND INCHES
            % The three lowest wvar are mm, the next 3 are 1/8inch
            min_K_Wvar = mink(distScanlinesONEslo.w_var(distScanlinesONEslo.w_var>0),6);
            min_K_table = distScanlinesONEslo(ismember(distScanlinesONEslo.w_var,min_K_Wvar),:);

            min_Wvar_Ypos = min_K_table{min_K_table.w_var == min_Wvar,4}; %%%%%%%%%% set for 10 columns %%%%%%%%%%%%
            min_Wvar_method = min_K_table{min_K_table.w_var == min_Wvar,3};%%%%%%%%%% set for 10 columns %%%%%%%%%%%
            min_Wvar_CONV_FACTOR = min_K_table{min_K_table.w_var == min_Wvar,10};%%%%%%%% set for 10 columns %%%%%%%%%%%%%%
            if length(min_Wvar_Ypos)>1,min_Wvar_Ypos = min_Wvar_Ypos(1);end
            if length(min_Wvar_CONV_FACTOR)>1,min_Wvar_CONV_FACTOR = median(min_Wvar_CONV_FACTOR);end
            if length(min_Wvar_method)>1,min_Wvar_method = min_Wvar_method{1};end

            % Split into bimodal
            try
                GMModel = fitgmdist(min_K_table.dist_geo,2);
                ConvFactor_mm = min(GMModel.mu);
                ConvFactor_imp = max(GMModel.mu);
            catch
                if isempty(min_Wvar)
                    ConvFactor_mm = 0;
                    min_Wvar_Ypos = 0;
                    ConvFactor_imp = 0;
                else
                    ConvFactor_mm = min_Wvar_CONV_FACTOR;
                    ConvFactor_imp = 0;                
                end
            end

            % Test for imp unit (1/16 inch)
            test_imp_16 = ConvFactor_mm*1.5875;
            test_imp_8 = ConvFactor_mm*3.175;
            test_imp_4 = ConvFactor_mm*6.35;

            % If mm times conversion is within 1% of the GMMvalue, then the
            % metric and imperial units were both found, otherwise I assume
            % that the succesful value is *min_Wvar*
            CF = cell(1,length(distHeadersCF));
            CFt = cell2table(CF);
            CFt.Properties.VariableNames = distHeadersCF;
            if isempty(min_Wvar)
                CFt.name = NAME;
                CFt.scan = SCAN;
                CFt.method = "Fail";
                CFt.w_var = NaN;
                CFt.yPosition = NaN;
                CFt.ConvFactor_mm = NaN;
                CFt.ConvFactor_imp = NaN;
                CFt.imp_unit = NaN;
                ConvFactor = [ConvFactor;CFt];
            else
                if ((ConvFactor_imp*0.99 <= test_imp_16) && (test_imp_16 <= ConvFactor_imp*1.01))
                    % We are certain of mm and 1/16inch parity
                    CFt.name = NAME;
                    CFt.scan = SCAN;
                    CFt.method = min_Wvar_method;
                    CFt.w_var = min_Wvar;
                    CFt.yPosition = min_Wvar_Ypos;
                    CFt.ConvFactor_mm = ConvFactor_mm;
                    CFt.ConvFactor_imp = ConvFactor_imp;
                    CFt.imp_unit = "1_16";
                    ConvFactor = [ConvFactor;CFt];
                elseif ((ConvFactor_imp*0.98 <= test_imp_8) && (test_imp_8 <= ConvFactor_imp*1.02))
                    % We are certain of mm and 1/8inch parity 
                    CFt.name = NAME;
                    CFt.scan = SCAN;
                    CFt.method = min_Wvar_method;
                    CFt.w_var = min_Wvar;
                    CFt.yPosition = min_Wvar_Ypos;
                    CFt.ConvFactor_mm = ConvFactor_mm;
                    CFt.ConvFactor_imp = ConvFactor_imp;
                    CFt.imp_unit = "1_8";
                    ConvFactor = [ConvFactor;CFt];
                elseif ((ConvFactor_imp*0.96 <= test_imp_4) && (test_imp_4 <= ConvFactor_imp*1.04))
                    % We are certain of mm and 1/4inch parity 
                    CFt.name = NAME;
                    CFt.scan = SCAN;
                    CFt.method = min_Wvar_method;
                    CFt.w_var = min_Wvar;
                    CFt.yPosition = min_Wvar_Ypos;
                    CFt.ConvFactor_mm = ConvFactor_mm;
                    CFt.ConvFactor_imp = ConvFactor_imp;
                    CFt.imp_unit = "1_4";
                    ConvFactor = [ConvFactor;CFt];
                else
                    % Only rely on *min_Wvar* min_Wvar_CONV_FACTOR
                    CFt.name = NAME;
                    CFt.scan = SCAN;
                    CFt.method = min_Wvar_method;
                    CFt.w_var = min_Wvar;
                    CFt.yPosition = min_Wvar_Ypos;
                    CFt.ConvFactor_mm = min_Wvar_CONV_FACTOR; %%%%
                    CFt.ConvFactor_imp = NaN;
                    CFt.imp_unit = "NA";
                    ConvFactor = [ConvFactor;CFt];
                end
            end%isempty(min_Wvar)

    %         [lowestVar, i_lowestVar] = min(MIN(MIN>0));
    %         lowestVar_data = distScanlines(i_lowestVar,:);
            %PASS = [PASS; lowestVar_data];
            %LOWEST = [LOWEST; lowestVar_data];
        end
    end % end "blocks" only
    
    %writetable(distScanlines,strcat(outDir,"distScanlines\",filename,"_distScanlines",".xlsx"))
    
% See if this works for blocks too, will need to unpack    
    
    %%%%%%% ADD QC to this, cross reference other values to give a
    %%%%%%% certainty
    %ConvFactor_geomean = geomean(ConvFactor.ConvFactor_mm);
    if isempty(min_Wvar)
    CONVERSION_FACTOR = "NA";
    CONVERSION_METHOD = "Fail";
    else
    CONVERSION_FACTOR = ConvFactor{find(min(ConvFactor.w_var)),6};
    CONVERSION_METHOD = ConvFactor{find(min(ConvFactor.w_var)),3};

    % Save QC Image
    xPTS = imgPOINTS{imgPOINTS.Yimg==min_Wvar_Ypos,2};
    xPTS = xPTS{1};
    yPTS = imgPOINTS{imgPOINTS.Yimg==min_Wvar_Ypos,3};
    yPTS = yPTS{1};

    if isnan(xPTS)
        %imwrite(img,strcat(outDir,"Overlay\",filename,"_Overlay",".jpg"))
        imgPrint = [];
    else
        [H,W,~] = size(img);
        imgPrint = img;
        BLANK = zeros(H,W);
        BLANK(repmat(min_Wvar_Ypos,1,length(yPTS)),round(xPTS)) = 1;
        BLANK = imbinarize(BLANK);
        SC = imdilate(BLANK,strel('diamond',1));
        [SCy,SCx] = find(SC);
        if CONVERSION_METHOD == "Harris"
            imgPrint(SCy,SCx,1) = 0; %blue
            imgPrint(SCy,SCx,2) = 255; %blue
            imgPrint(SCy,SCx,3) = 255; %blue
        elseif CONVERSION_METHOD == "Peaks"
            imgPrint(SCy,SCx,1) = 0; %green
            imgPrint(SCy,SCx,2) = 255; %green
            imgPrint(SCy,SCx,3) = 0; %green
        end
        %imshow(imgPrint)
        %imwrite(imgPrint,strcat(outDir,"Overlay\",filename,"_Overlay",".jpg"))
    end
    end%isempty(min_Wvar)