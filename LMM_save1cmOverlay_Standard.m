function KEEP = LMM_save1cmOverlay_Standard(usedTable,imgPOINTS,imgSet,imgProps,setParameters,dirList,indObject)
    imgPrint = imgSet.img;
    color = ['g';'b';'y'];
    DOUBLE = 0;
    yJitter = 5;
    for nPlot = 1:height(usedTable)
        imgPOINTS2 = imgPOINTS(imgPOINTS.Scan == usedTable.scan(nPlot),:);
        conversionFactor = usedTable.dist_geo(nPlot);
        yPos = usedTable.yPosition(nPlot);

        % Save QC Image
        xPTS = [];
        yPTS = [];
        XY = [];
        linePtsX = [];
        linePtsY = [];
        lineStart = [];
        SC = [];
        KEEP = [];
        
        
        xPTS = imgPOINTS2{imgPOINTS2.Yimg == usedTable.yPosition(nPlot),3};
        xPTS = xPTS{1};
        yPTS = imgPOINTS2{imgPOINTS2.Yimg == usedTable.yPosition(nPlot),4};
        yPTS = yPTS{1};

        X = xPTS';
        Y = yPTS';
        XY = [X,Y];

        % This finds approximate points to plot, if returns zero, just skip and plot the line
        KEEP = filterForConvDistance(XY,conversionFactor);
        if isempty(KEEP)
            KEEP = XY;
        end

        % Determine and format points to plot
        [H,W,~] = size(imgPrint);

        blank = zeros(H,W);
        blank(repmat(yPos,1,length(KEEP(:,2))),round(KEEP(:,1))) = 1;
        blank = imbinarize(blank);
        SC = imdilate(blank,strel('diamond',1));
        [SCy,SCx] = find(SC);

        if nPlot == 1
            stretchFactor = 10; % Assumes mm.
            if contains(usedTable.ConversionMessage(nPlot),"1_2mm_to_1mm")
                stretchFactor = 20;
                DOUBLE = 1;
            elseif contains(usedTable.ConversionMessage(nPlot),"small_tick_half_of_large")
                stretchFactor = 20;
                DOUBLE = 1;
            end
        else
            if contains(usedTable.ConversionMessage(nPlot),"1_2mm_to_1mm")
                if DOUBLE
                    stretchFactor = 10;
                else
                    stretchFactor = 20;
                end
            elseif contains(usedTable.ConversionMessage(nPlot),"small_tick_half_of_large")
                if DOUBLE
                    stretchFactor = 10;
                else
                    stretchFactor = 20;
                end
            elseif contains(usedTable.ConversionMessage(nPlot),"1_16")
                stretchFactor = 16;
            elseif contains(usedTable.ConversionMessage(nPlot),"1_8")
                stretchFactor = 8;
            elseif contains(usedTable.ConversionMessage(nPlot),"1_4")
                stretchFactor = 4;
            elseif contains(usedTable.ConversionMessage(nPlot),"1_2")
                stretchFactor = 2;
            end
        end          
        
        % 1cm Line
        lineStart = SCx(round(length(SCx) / 2));

        linePtsX = lineStart:lineStart + round(conversionFactor * stretchFactor);%%%%%%%%%%%%%%%%%%%%%%%%%%update *10

        linePtsY(1:length(linePtsX), 1) =  SCy(round(length(SCx) / 2));


        % Plot points and 1 cm. line overlay
        try
            imgPrint = overlay1cmLinePts(color(nPlot),imgPrint, SCx, SCy, linePtsX, linePtsY+yJitter);
        catch
            imgPrint = overlay1cmLinePts(color(nPlot),imgPrint, SCx, SCy, linePtsX, linePtsY); % incase the jitter is our of bounds
        end
        
        
        figure(7);
        imshow(imgPrint)
        %imshow(imgPrint2)
        
        
    
    end
    if setParameters.printRulerOverlay
        imwrite(imgPrint,fullfile(dirList.rulerOverlay,strcat(imgProps.filename,"_RulerOverlay_",indObject,".jpg")))
    end
end


function KEEP = filterForConvDistance(XY,CONVERSION_FACTOR)
    KEEP = [];
    bufferUp = CONVERSION_FACTOR * 1.1;
    bufferDn = CONVERSION_FACTOR * 0.9;
    for i = 1:length(XY)
        START = XY(i,:);
        for j = 1:length(XY)
            GO = XY(j,:);
            dist = sqrt(sum((GO-START).^2));
            if ((dist <= bufferUp) && (dist >= bufferDn))
                KEEP = [KEEP; GO];
            end

        end
    end
end

function imgPrint = overlay1cmLinePts(color,imgPrint,SCx,SCy,linePtsX,linePtsY)
    
    if color == 'g'
        imgPrint(SCy,SCx,1) = 0; %green
        imgPrint(SCy,SCx,2) = 255; %green
        imgPrint(SCy,SCx,3) = 0; %green
        
        imgPrint(linePtsY,linePtsX,1) = 0; %green
        imgPrint(linePtsY,linePtsX,2) = 255; %green
        imgPrint(linePtsY,linePtsX,3) = 0; %green

        imgPrint(linePtsY+1,linePtsX,1) = 0; %green
        imgPrint(linePtsY+1,linePtsX,2) = 255; %green
        imgPrint(linePtsY+1,linePtsX,3) = 0; %green

        imgPrint(linePtsY-1,linePtsX,1) = 0; %green
        imgPrint(linePtsY-1,linePtsX,2) = 255; %green
        imgPrint(linePtsY-1,linePtsX,3) = 0; %green
        
    elseif color == 'b'
        imgPrint(SCy,SCx,1) = 0; %blue
        imgPrint(SCy,SCx,2) = 255; %blue
        imgPrint(SCy,SCx,3) = 255; %blue
        
        imgPrint(linePtsY,linePtsX,1) = 0; %blue
        imgPrint(linePtsY,linePtsX,2) = 255; %blue
        imgPrint(linePtsY,linePtsX,3) = 255; %blue

        imgPrint(linePtsY+1,linePtsX,1) = 0; %blue
        imgPrint(linePtsY+1,linePtsX,2) = 255; %blue
        imgPrint(linePtsY+1,linePtsX,3) = 255; %blue

        imgPrint(linePtsY-1,linePtsX,1) = 0; %blue
        imgPrint(linePtsY-1,linePtsX,2) = 255; %blue
        imgPrint(linePtsY-1,linePtsX,3) = 255; %blue
        
    elseif color == 'y'
        imgPrint(SCy,SCx,1) = 255; %blue
        imgPrint(SCy,SCx,2) = 255; %blue
        imgPrint(SCy,SCx,3) = 0; %blue
        
        imgPrint(linePtsY,linePtsX,1) = 255; %blue
        imgPrint(linePtsY,linePtsX,2) = 255; %blue
        imgPrint(linePtsY,linePtsX,3) = 0; %blue

        imgPrint(linePtsY+1,linePtsX,1) = 255; %blue
        imgPrint(linePtsY+1,linePtsX,2) = 255; %blue
        imgPrint(linePtsY+1,linePtsX,3) = 0; %blue

        imgPrint(linePtsY-1,linePtsX,1) = 255; %blue
        imgPrint(linePtsY-1,linePtsX,2) = 255; %blue
        imgPrint(linePtsY-1,linePtsX,3) = 0; %blue
    end

end