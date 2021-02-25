function LMM_save1cmOverlay_Blocks(imgSet,imgProps,dirList,blocksData,indObject)
    % Unpack
    plotPts = blocksData.plotPts;
    convFactor = blocksData.convFactorCM;
    
    % Determine and format points to plot
    [H,W,~] = size(imgSet.img);
    imgPrint = imgSet.img;
    BLANK = zeros(H,W);
    BLANK(repmat(round(blocksData.yPosition),1,length(plotPts(:,2))),plotPts(:,1)) = 1;
    BLANK = imbinarize(BLANK);
    SC = imdilate(BLANK,strel('diamond',1));
    [SCy,SCx] = find(SC);
    
    %1cm line
    lineStart = SCx(round(length(SCx)/2));
    linePtsX = lineStart:lineStart+round(convFactor);%% multiply by 10 if ConvFactor is in mm.
    linePtsY(1:length(linePtsX), 1) =  SCy(round(length(SCx)/2));


    % Plot points and 1 cm. line overlay
    imgPrint = overlay1cmLine_Blocks(imgPrint,SCx,SCy,linePtsX,linePtsY);

    %figure(7);
    %imshow(imgPrint)
    imwrite(imgPrint,fullfile(dirList.rulerOverlay,strcat(imgProps.filename,"_RulerOverlay_",indObject,".jpg")))


end


function imgPrint = overlay1cmLine_Blocks(imgPrint,SCx,SCy,linePtsX,linePtsY)

    % Points
    imgPrint(SCy,SCx,1) = 0; %green
    imgPrint(SCy,SCx,2) = 255; %green
    imgPrint(SCy,SCx,3) = 0; %green

    % Line
    imgPrint(linePtsY,linePtsX,1) = 0; %green
    imgPrint(linePtsY,linePtsX,2) = 255; %green
    imgPrint(linePtsY,linePtsX,3) = 0; %green

    imgPrint(linePtsY+1,linePtsX,1) = 0; %green
    imgPrint(linePtsY+1,linePtsX,2) = 255; %green
    imgPrint(linePtsY+1,linePtsX,3) = 0; %green

    imgPrint(linePtsY-1,linePtsX,1) = 0; %green
    imgPrint(linePtsY-1,linePtsX,2) = 255; %green
    imgPrint(linePtsY-1,linePtsX,3) = 0; %green
end