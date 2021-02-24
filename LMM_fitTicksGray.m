function LMM_fitTicksGray(imgBW,imgProps,dirList,type,color)
% For testing
        IMG_run = imgBW;
        numWhitePixels = sum(imgBW(:));
        numBlackPixels = sum(~imgBW(:));
        if numWhitePixels>= numBlackPixels, imgBW = imcomplement(imgBW);end
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
        SCAN = strcat("scan",string(ii));
        
        [scanlineCropImgs,scanlineCropHpts] = scanlineCrop(IMG_run,IMG_pts,ii);
        
        for i=1:length(scanlineCropImgs)
            ADDpts1 = cell(1,length(distHeadersP));
            ADDpts = cell2table(ADDpts1);
            ADDpts.Properties.VariableNames = distHeadersP; 
            yPosOverall = ((ii/2)*i);
            yPosScan = ii/2;
            [TABLE,POINTS] = fitTicks_MM_blackTicks(scanlineCropImgs{i},TYPE,scanlineCropHpts{i},IMG_pts,0,distHeaders,NAME,SCAN,yPosOverall,yPosScan);
            distScanlinesONEslo = [distScanlinesONEslo;TABLE];%slo = one scan line option only
            distScanlines = [distScanlines;TABLE];
            ADDpts.Yimg = yPosOverall;
            ADDpts.Scan = SCAN;
            if isempty(POINTS) == 1
                ADDpts.x = {NaN};
                ADDpts.y = {NaN};
            else
                ADDpts.x = {POINTS(1,:)};
                ADDpts.y = {POINTS(2,:)};
            end
            imgPOINTS = [imgPOINTS;ADDpts];
        end
        
        %%% If "gray" there must be between 7 and 21 tick marks!
        if TYPE == "gray"
            distScanlinesONEslo = distScanlinesONEslo(distScanlinesONEslo.n_peaks < 21,:);
            distScanlinesONEslo = distScanlinesONEslo(distScanlinesONEslo.n_peaks > 7,:);
            % This assumes that the cropped ruler is nearly bounding,
            % allows for "10-30cm" to be encompassed by the width of the crop
            WIDTH = W./distScanlinesONEslo.dist_geo;
            WIDTHi = find(WIDTH<30 & WIDTH > 10);
            distScanlinesONEslo = distScanlinesONEslo(WIDTHi,:);
        end
        
        
        if length(distScanlinesONEslo.n_peaks) == 0 
            min_Wvar=0;
            CF = cell(1,length(distHeadersCF));
            CFt = cell2table(CF);
            CFt.Properties.VariableNames = distHeadersCF;
            CFt.name = NAME;
            CFt.scan = SCAN;
            CFt.method = "Fail 7-21 and 10-30cm";
            CFt.w_var = NaN;
            CFt.yPosition = NaN;
            CFt.ConvFactor_mm = NaN;
            CFt.ConvFactor_imp = NaN;
            CFt.imp_unit = NaN;
            CFt.nPeaks = NaN;
            ConvFactor = [ConvFactor;CFt];
        else
        
        min_Wvar = min(distScanlinesONEslo.w_var(distScanlinesONEslo.w_var>0));
        
        %%% METHOD TO FIND CM AND INCHES
        % The three lowest wvar are mm, the next 3 are 1/8inch
        min_K_Wvar = mink(distScanlinesONEslo.w_var(distScanlinesONEslo.w_var>0),  5  ); %%%%%%%%%%%%% column 5 is w_var
        min_K_table = distScanlinesONEslo(ismember(distScanlinesONEslo.w_var,min_K_Wvar),:);
        
        min_Wvar_Ypos = min_K_table{min_K_table.w_var == min_Wvar,4}; %%%%%%%%%% set for 10 columns %%%%%%%%%%%%
        min_Wvar_method = min_K_table{min_K_table.w_var == min_Wvar,3};%%%%%%%%%% set for 10 columns %%%%%%%%%%%
        min_Wvar_CONV_FACTOR = min_K_table{min_K_table.w_var == min_Wvar,10};%%%%%%%% set for 10 columns %%%%%%%%%%%%%%
        min_Wvar_nPeaks = min_K_table{min_K_table.w_var == min_Wvar,7};%%%%%%%% set for 10 columns %%%%%%%%%%%%%%
        if length(min_Wvar_Ypos)>1,min_Wvar_Ypos = min_Wvar_Ypos(1);end
        if length(min_Wvar_CONV_FACTOR)>1,min_Wvar_CONV_FACTOR = median(min_Wvar_CONV_FACTOR);end
        if length(min_Wvar_method)>1,min_Wvar_method = min_Wvar_method{1};end
        if length(min_Wvar_nPeaks)>1,min_Wvar_nPeaks = min_Wvar_nPeaks(1);end
        
        % Split into bimodal %%%%%% GMModel Option %%%%%%
        CheckRange = 0;
        try
            GMModel = fitgmdist(min_K_table.dist_geo,2);
            ConvFactor_mm = min(GMModel.mu);
            ConvFactor_imp = max(GMModel.mu);
            if abs(ConvFactor_mm-ConvFactor_imp) > ConvFactor_mm*0.05

                %%%%%%%%%%%%%%%%%%% get the nearest geomean NOT the model
                %%%%%%%%%%%%%%%%%%% number!!! then grab the ypos and swapp them
                %%%%%%%%%%%%%%%%%%% too if needed, for plotting

                if TYPE == "gray"
                    [opt1,CON] = checkConversionForGrayRulers_GMModel(ConvFactor_mm,ConvFactor_imp); % opt1==1 --> swapped the inputs
                    if opt1 == 0
                        ConvFactor_mm = max(GMModel.mu);
                        ConvFactor_imp = min(GMModel.mu);
                    end
                    % MM
                    closeMM = min_K_table{(min_K_table.dist_geo < (ConvFactor_mm*1.02)),10};
                    closeMM = closeMM(closeMM > (ConvFactor_mm*0.98));
                    closeMM_Table = min_K_table(ismember(min_K_table.dist_geo,closeMM),:);

                    min_Wvar = min(closeMM_Table.w_var(closeMM_Table.w_var>0));
                    min_Wvar_Ypos = closeMM_Table{closeMM_Table.w_var == min_Wvar,4}; %%%%%%%%%% set for 10 columns %%%%%%%%%%%%
                    min_Wvar_method = closeMM_Table{closeMM_Table.w_var == min_Wvar,3};%%%%%%%%%% set for 10 columns %%%%%%%%%%%
                    min_Wvar_CONV_FACTOR = closeMM_Table{closeMM_Table.w_var == min_Wvar,10};%%%%%%%% set for 10 columns %%%%%%%%%%%%%%
                    min_Wvar_nPeaks = closeMM_Table{closeMM_Table.w_var == min_Wvar,7};%%%%%%%% set for 10 columns %%%%%%%%%%%%%%
                    if length(min_Wvar_Ypos)>1,min_Wvar_Ypos = min_Wvar_Ypos(1);end
                    if length(min_Wvar_CONV_FACTOR)>1,min_Wvar_CONV_FACTOR = median(min_Wvar_CONV_FACTOR);end
                    if length(min_Wvar_method)>1,min_Wvar_method = min_Wvar_method{1};end
                    if length(min_Wvar_nPeaks)>1,min_Wvar_nPeaks = min_Wvar_nPeaks(1);end

                    % IMP
                    closeIMP = min_K_table{(min_K_table.dist_geo < (ConvFactor_imp*1.02)),10};
                    closeIMP = closeIMP(closeIMP > (ConvFactor_imp*0.98));
                    closeIMP_Table = min_K_table(ismember(min_K_table.dist_geo,closeIMP),:);

                    min_Wvar_IMP = min(closeIMP_Table.w_var(closeIMP_Table.w_var>0));
                    min_Wvar_Ypos_IMP = closeIMP_Table{closeIMP_Table.w_var == min_Wvar_IMP,4}; %%%%%%%%%% set for 10 columns %%%%%%%%%%%%
                    min_Wvar_method_IMP = closeIMP_Table{closeIMP_Table.w_var == min_Wvar_IMP,3};%%%%%%%%%% set for 10 columns %%%%%%%%%%%
                    min_Wvar_CONV_FACTOR_IMP = closeIMP_Table{closeIMP_Table.w_var == min_Wvar_IMP,10};%%%%%%%% set for 10 columns %%%%%%%%%%%%%%
                    min_Wvar_nPeaks_IMP = closeIMP_Table{closeIMP_Table.w_var == min_Wvar_IMP,7};%%%%%%%% set for 10 columns %%%%%%%%%%%%%%
                    if length(min_Wvar_Ypos_IMP)>1,min_Wvar_Ypos_IMP = min_Wvar_Ypos_IMP(1);end
                    if length(min_Wvar_CONV_FACTOR_IMP)>1,min_Wvar_CONV_FACTOR_IMP = median(min_Wvar_CONV_FACTOR_IMP);end
                    if length(min_Wvar_method_IMP)>1,min_Wvar_method_IMP = min_Wvar_method_IMP{1};end
                    if length(min_Wvar_nPeaks_IMP)>1,min_Wvar_nPeaks_IMP = min_Wvar_nPeaks_IMP(1);end
                    
                    
                    if checkYposSpread(SCAN,min_Wvar_Ypos_IMP,min_Wvar_Ypos) == 1 %%%%% This is an important check. greyTiffen_Dual__382__1 incidentally has a pattern that yeilds 1/2inch symptoms, so if yPos is too close, swap and go with the "imp" as the metric, DELETE the imp
                        min_Wvar = min_Wvar_IMP;
                        min_Wvar_Ypos = min_Wvar_Ypos_IMP;
                        min_Wvar_method = min_Wvar_method_IMP;
                        min_Wvar_CONV_FACTOR = min_Wvar_CONV_FACTOR_IMP;
                        min_Wvar_nPeaks = min_Wvar_nPeaks_IMP;
                        ConvFactor_mm = min_Wvar_CONV_FACTOR;
                        % delete the imp data since it's too unreliable
                        min_Wvar_IMP = "NA";
                        min_Wvar_Ypos_IMP = "NA";
                        min_Wvar_method_IMP = "NA";
                        min_Wvar_CONV_FACTOR_IMP = "NA";
                        min_Wvar_nPeaks_IMP = "NA";
                        ConvFactor_imp = 0;
                    end
                end
            else
                H = NA;
            end % abs difference, making sure that GMModel finds appropriate difference
        catch
            try %%%%%%% CheckRange Option %%%%%%% Take the min_Wvar_CONV_FACTOR, see if it's a conversion to the other dist_geos 
                [CheckRange,method_CR,w_var_CR,yPosition_CR,ConvFactor_mm_CR,ConvFactor_imp_CR,imp_unit_CR,nPeaks_CR] = checkConversionForGrayRulers_CheckRange(min_K_table,min_Wvar,min_Wvar_Ypos,min_Wvar_method,min_Wvar_CONV_FACTOR,min_Wvar_nPeaks,SCAN);
                
                ConvFactor_mm = ConvFactor_mm_CR;
                ConvFactor_imp = ConvFactor_imp_CR;
                 min_Wvar_Ypos = yPosition_CR;
                CON = imp_unit_CR;
            catch % No possibility to cross validate
                if isempty(min_Wvar)
                    ConvFactor_mm = 0;
                    min_Wvar_Ypos = 0;
                    ConvFactor_imp = 0;
                    CON = "NA";
                else
                    ConvFactor_mm = min_Wvar_CONV_FACTOR;
                    ConvFactor_imp = 0;   
                    CON = "NA";
                end
            end
        end
        
        
        
        % REDO THIS TO MAKE IT MORE LIKE GRAY RULERS CHECK!!!!!!!!!!!!

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
            CFt.imp_unit = CON;
            CFt.nPeaks = NaN;
            ConvFactor = [ConvFactor;CFt];
            
        elseif CheckRange == 1   
            CFt.name = NAME;
            CFt.scan = SCAN;
            CFt.method = method_CR;
            CFt.w_var = w_var_CR;
            CFt.yPosition = yPosition_CR;
            CFt.ConvFactor_mm = ConvFactor_mm_CR;
            CFt.ConvFactor_imp = ConvFactor_imp_CR;
            CFt.imp_unit = imp_unit_CR;
            CFt.nPeaks = nPeaks_CR;
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
                CFt.nPeaks = min_Wvar_nPeaks;
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
                CFt.nPeaks = min_Wvar_nPeaks;
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
                CFt.nPeaks = min_Wvar_nPeaks;
                ConvFactor = [ConvFactor;CFt];
            else
                % Only rely on *min_Wvar* min_Wvar_CONV_FACTOR
                CFt.name = NAME;
                CFt.scan = SCAN;
                CFt.method = min_Wvar_method;
                CFt.w_var = min_Wvar;
                CFt.yPosition = min_Wvar_Ypos;
                CFt.ConvFactor_mm = ConvFactor_mm; %%%%
                CFt.ConvFactor_imp = ConvFactor_imp;
                CFt.imp_unit = CON;
                CFt.nPeaks = min_Wvar_nPeaks;
                ConvFactor = [ConvFactor;CFt];
            end
        end%isempty(min_Wvar)

%         [lowestVar, i_lowestVar] = min(MIN(MIN>0));
%         lowestVar_data = distScanlines(i_lowestVar,:);
        %PASS = [PASS; lowestVar_data];
        %LOWEST = [LOWEST; lowestVar_data];
        end
    end
    
    writetable(distScanlines,strcat(OutDir,"distScanlines\",filename,"_distScanlines",".xlsx")) %%%%%% Good spot to jump in for troubleshooting
    
    %%%%%% Determine conversion final value %%%%%
    
    % If min_Wvar isempty, then there were no good measurements
    if isempty(min_Wvar)
        CONVERSION_FACTOR = "NA";
        CONVERSION_METHOD = "All Methods Failed";
    else
        % Set all values to NA
        SCANLINE_FINAL = "NA";
        SCANLINE_YPOS = "NA";
        CONVERSION_FACTOR = "NA";
        CONVERSION_METHOD = "NA";
        CONVERSION_FACTOR_nPeaks = "NA";
        CONVERSION_FACTOR_IMP_UNIT = "NA";
        
        %%% Critical Function
        %%% Kodak and Tiffen only have 1cm marks, so final value needs to be
        %%% converted to mm
        if TYPE == "gray"
            
            % This function finds any conversions, AND will determine if
            % there is cross validation between metric and imperial
            [SCANLINE_FINAL,SCANLINE_YPOS,CONVERSION_FACTOR,CONVERSION_METHOD,CONVERSION_FACTOR_IMP_UNIT,CONVERSION_FACTOR_nPeaks] = checkConversionForGrayRulers(ConvFactor);
            
        end
        
        % If checkConversionForGrayRulers failed to reslove (which is
        % typical) then we have to determine the best of the 3 possibilities
        % in ConvFactor. priority
        if SCANLINE_FINAL == "NA" % can accept a failed graycheck or a nongray  

            min_w_Var_VAL = min(ConvFactor.w_var);
            min_w_Var_VAL_INDEX = find(ConvFactor.w_var == min_w_Var_VAL);

            % If there is a tie take the first OR the peaks
            METHOD_VAL = ConvFactor.method(min_w_Var_VAL_INDEX);
            if ismember("Peaks",METHOD_VAL)%take the "peaks" indicies
                IND_PEAKS = find(METHOD_VAL=="Peaks");
                IND_PEAKSonly = min_w_Var_VAL_INDEX(IND_PEAKS);
                if length(IND_PEAKSonly) > 1 %if there are still more than 1 "peaks" remanining take the first
                    min_w_Var_VAL_INDEX = IND_PEAKSonly(1);
                end
            else%take the first
                if length(min_w_Var_VAL_INDEX) > 1, min_w_Var_VAL_INDEX = min_w_Var_VAL_INDEX(1);end
            end
            SCANLINE_FINAL = ConvFactor{min_w_Var_VAL_INDEX,2};
            SCANLINE_YPOS = ConvFactor{min_w_Var_VAL_INDEX,4};
            CONVERSION_FACTOR = ConvFactor{min_w_Var_VAL_INDEX,6};
            CONVERSION_METHOD = ConvFactor{min_w_Var_VAL_INDEX,3};
            CONVERSION_FACTOR_nPeaks = ConvFactor{min_w_Var_VAL_INDEX,9};
            if TYPE == "gray"
                CONVERSION_FACTOR_IMP_UNIT = "Gray_SingleValidation_MinWVar";
            else
                CONVERSION_FACTOR_IMP_UNIT = "Tick_SingleValidation_MinWVar";
            end
        end
        
        
        if TYPE == "gray"
            CONVERSION_FACTOR = CONVERSION_FACTOR/10; % Gray always returns 1cm pixel conversion values
        else
        end

        
        if isempty(SCANLINE_FINAL)
            xPTS = NaN;
            SCANLINE_FINAL = "NA";
            SCANLINE_YPOS = "NA";
            CONVERSION_FACTOR = "NA";
            CONVERSION_METHOD = "Methods Failed to Resolve";
            CONVERSION_FACTOR_nPeaks = "NA";
        else
            imgPOINTS_2 = imgPOINTS(imgPOINTS.Scan == SCANLINE_FINAL,:);

            % Save QC Image
            xPTS = [];
            yPTS = [];
            xPTS = imgPOINTS_2{imgPOINTS_2.Yimg==SCANLINE_YPOS,3};
            xPTS = xPTS{1};
            yPTS = imgPOINTS_2{imgPOINTS_2.Yimg==SCANLINE_YPOS,4};
            yPTS = yPTS{1};
        end
        
        
        if isnan(xPTS)
            imwrite(img,strcat(OutDir,"Overlay\",filename,"_Overlay",".jpg"))
        else
            
            % Determine and format points to plot
            [H,W,~] = size(img);
            imgPrint = img;
            BLANK = zeros(H,W);
            BLANK(repmat(SCANLINE_YPOS,1,length(yPTS)),round(xPTS)) = 1;
            BLANK = imbinarize(BLANK);
            SC = imdilate(BLANK,strel('diamond',1));
            [SCy,SCx] = find(SC);
            %1cm line
            lineStart = SCx(round(length(SCx)/2));
            if TYPE == "gray"
                linePtsX = lineStart:lineStart+round(CONVERSION_FACTOR*10);%%%%%%%%%%%%%%%%%%%%%%%%%%update *10
            else
                linePtsX = lineStart:lineStart+round(CONVERSION_FACTOR);
            end
            linePtsY(1:length(linePtsX), 1) =  SCy(round(length(SCx)/2));

            
            % Plot points and 1 cm. line overlay
            if (CONVERSION_METHOD == "Harris") || (CONVERSION_METHOD == "Harris_CheckRange"), CONVERSION_METHOD_print = "Harris";end
            if (CONVERSION_METHOD == "Peaks") || (CONVERSION_METHOD == "Peaks_CheckRange"), CONVERSION_METHOD_print = "Peaks";end
            
            if CONVERSION_METHOD_print == "Harris"
                imgPrint = overlay_1cmLine_Pts(CONVERSION_METHOD_print,CONVERSION_FACTOR_IMP_UNIT,imgPrint,SCx,SCy,linePtsX,linePtsY);
            elseif CONVERSION_METHOD_print == "Peaks"
                imgPrint = overlay_1cmLine_Pts(CONVERSION_METHOD_print,CONVERSION_FACTOR_IMP_UNIT,imgPrint,SCx,SCy,linePtsX,linePtsY);
            end
            %figure(7);
            %imshow(imgPrint)
            imwrite(imgPrint,strcat(OutDir,"Overlay\",filename,"_Overlay",".jpg"))
            
            
        end
    end%isempty(min_Wvar)
    
    distSummaryt = cell(1,length(distHeaders2));
    distSummaryt = cell2table(distSummaryt);
    distSummaryt.Properties.VariableNames = distHeaders2;
    distSummaryt.name = NAME;
    distSummaryt.scanline = string(SCANLINE_YPOS);
    distSummaryt.calculated_dist = CONVERSION_FACTOR;     %%%%%%%%%%%%%need this to be in mm =good for gray
    distSummaryt.method = CONVERSION_METHOD;
    distSummaryt.imperialUnit = CONVERSION_FACTOR_IMP_UNIT;
    distSummaryt.nPeaks = CONVERSION_FACTOR_nPeaks;%%

end