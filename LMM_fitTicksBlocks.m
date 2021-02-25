function dataOut = LMM_fitTicksBlocks(imgBW)

    BW = bwareafilt(imgBW,20,'largest');
    
    props = regionprops('table',BW, 'Centroid','Circularity','BoundingBox','MajorAxisLength');
    
    majorLen = props.MajorAxisLength;
    majorLenRO = rmoutliers(majorLen,'gesd');
    majorLenROpeaks = findpeaks(majorLenRO);
    majorLenROpeaksRO = rmoutliers(majorLenROpeaks,'gesd');
    geoMean = geomean(majorLenROpeaksRO);
    
    upperB = 1.05*geoMean;
    lowerB = 0.95*geoMean;
    indBest = ((majorLen >= lowerB) & (majorLen <= upperB));
    
    bestTable = props(indBest,:);
    
    %%% Test for two rows of blocks, test for offset squares
    if height(bestTable) == 1
        plotPts = [];
        convFactorCM = [];
        convFactorMM = [];
        variance = [];
        nPeaks = [];
        wVar = [];
        yPosition = [];
        validation = [];
    else
        data = testForTwoRows(bestTable);
        % Save out
        convFactorCM = data.convFactor;
        convFactorMM = convFactorCM / 10;
        variance = data.v;
        nPeaks = data.nTerms;
        wVar = variance/nPeaks;
        yPosition = data.yPos;
        % Get locations of best points used to determine the conv factor
        plotPts = data.plotPts;
        validation = data.validation;
    end
    
    
    
    % Save out
    dataOut.props = bestTable; % Centroid(2cols), BBox(4cols), MajorAxisLength(1col), Circularity(1col)
    dataOut.convFactorCM = convFactorCM;
    dataOut.convFactorMM = convFactorMM;
    dataOut.variance = variance;
    dataOut.wVar = wVar;
    dataOut.nPeaks = nPeaks;
    dataOut.yPosition = yPosition;
    dataOut.plotPts = plotPts;
    dataOut.method = "blocks";
    dataOut.scan = "NA";
    dataOut.validation = validation;
end


function data = testForTwoRows(bestTable)
    
    idx = kmeans(bestTable.Centroid(:,2),2);
    
    [firstDistGeoMean,nTerms1,v1,y1] = calcPairwiseDistGeomean(bestTable,idx,1);
    [secondDistGeoMean,nTerms2,v2,y2] = calcPairwiseDistGeomean(bestTable,idx,2);
    
    DIST = [firstDistGeoMean; secondDistGeoMean];
    TERMS = [nTerms1; nTerms2];
    VAR = [v1; v2];
    I = [1; 2];
    Y = [y1; y2];
    
    big = max(DIST);
    small = min(DIST);
    
    % Calc ratio of large to small, if ~2, then we know the correct distance
    % for a ruler that has constant block + staggered blocks
    
    RATIO = big/small;
    
    % This is the typical high contrast block ruler
    upper = 2 * 1.05;
    lower = 2 * 0.95;
    
    % This is the offset square block ruler that will have even n blocks in each row
    upperEven = 1 * 1.05;
    lowerEven = 1 * 0.95;
    
    % Option 1 - Typical high contrast ruler wtih 9 1cm blocks and 1 cm of mm tickcs
    if ((RATIO <= upper) && (RATIO >= lower))
        convFactor = small;
        v = VAR(DIST == small);
        yPos = Y(DIST == small);
        nTerms = sum(TERMS); % TERMS(DIST == small); %Since cross val, sum the nTerms
        validation = "CrossVal_Two_Rows_of_Blocks_Uneven";
        plotPts = round(bestTable.Centroid);
        
    % Option 2 - Staggered blocks
    elseif ((RATIO <= upperEven) && (RATIO >= lowerEven))
        convFactor = small/2; % Divide by 2 because the 1cm. blocks are be staggered
        v = VAR(DIST == small);
        yPos = Y(DIST == small);
        nTerms = sum(TERMS);% TERMS(DIST == small); %Since cross val, sum the nTerms
        validation = "CrossVal_Two_Rows_of_Blocks_Even";
        plotPts = round(bestTable.Centroid);
       
    % Option 3 - only 1 row is found, defaults to dist associated with largest number of boxes found
    else
        if nTerms1 >= nTerms2
            nTerms = nTerms1;
            convFactor = DIST(TERMS == nTerms);
            v = VAR(TERMS == nTerms);
            yPos = Y(TERMS == nTerms);
            plotPts = round(bestTable.Centroid(idx == I(TERMS == nTerms),:));
        else
            nTerms = nTerms2;
            convFactor = DIST(TERMS == nTerms);
            v = VAR(TERMS == nTerms);
            yPos = Y(TERMS == nTerms);
            plotPts = round(bestTable.Centroid(idx == I(TERMS == nTerms),:));
        end
        validation = "SingleVal_One_Row_Blocks";
    end
    
    data.convFactor = convFactor;
    data.nTerms = nTerms;
    data.validation = validation;
    data.plotPts = plotPts;
    data.v = v;
    data.yPos = yPos;


end

function [firstDistGeoMean,nTerms,v,y] = calcPairwiseDistGeomean(bestTable,idx,choice)
    
    first = bestTable(idx == choice,:);
    
    firstDist = pdist(first.Centroid);
    firstDistMode = mode(firstDist);
    
    upperB = 1.05*firstDistMode;
    lowerB = 0.95*firstDistMode;
    bestDist = ((firstDist >= lowerB) & (firstDist <= upperB));
    
    firstDistGeoMean = geomean(firstDist(bestDist));
    v = var(firstDist(bestDist));
    nTerms = length(firstDist(bestDist));
    y = round(geomean(first.Centroid(:,2)));

end
