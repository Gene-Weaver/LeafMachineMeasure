function dist = LMM_fitTicksSURFpoints(boxPoints,img)

    Location = boxPoints.Location;
    
    % Create zeros vector to store data 
    MinDist = zeros(length(Location)-1,1);
    
    for i = 1:length(Location)
        LocationTemp = Location;
        Start = Location(i,:);
        LocationTemp(i,:) = [];
        % Euclidean distance between points
        distances = sqrt(sum(bsxfun(@minus, LocationTemp, Start).^2,2));
        MinDist(i,1) = min(distances);
    end
    
    % Create temporary vector
    MinDistTemp = MinDist;
    % Remove zero distances
    MinDist(MinDist(:,1)==0)=[];
    % Show density plot 
    [peakDensity,xi] = ksdensity(MinDist);
    [~,peakIndex] = max(peakDensity);
    % PeakLocation is the uncorrected pixel distance equal to 1mm
    peakLocation = xi(peakIndex);
    % All points within 10% of the peak density location
    PeakPoints = MinDistTemp((MinDistTemp(:,1)>=(.8*peakLocation)) & (MinDistTemp(:,1)<=(1.2*peakLocation)));

    PeakPointsLocation = zeros(length(Location)-1,2);
    for i = 1:length(Location)
        LocationTemp = Location;
        Start = Location(i,:);
        LocationTemp(i,:) = [];
        % Euclidean distance between points
        distances = sqrt(sum(bsxfun(@minus, LocationTemp, Start).^2,2));
        PeakMin = min(distances);
        if ((PeakMin >=(.9*peakLocation)) && (PeakMin<=(1.1*peakLocation)))
            PeakPointsLocation(i,:) = Start;
        else
            PeakPointsLocation(i,:) = 0; % make rows 0 if it is not within the range
        end
    end

    

    % Remove zero rows
    PeakPointsLocation(~any(PeakPointsLocation,2), : ) = [];

    RulerXRange = range(Location(:,1));
    RulerYRange = range(Location(:,2));
    if RulerXRange > RulerYRange
        % Ruler is horrizontal in image
        NormalizeX = polyfit(PeakPointsLocation(:,1),PeakPointsLocation(:,2),1);
        ApproxX = polyval(NormalizeX,PeakPointsLocation(:,1));
        CorrectedPoints = [PeakPointsLocation(:,1),ApproxX];
    else
        % Ruler is vertical in image
        NormalizeX = polyfit(PeakPointsLocation(:,2),PeakPointsLocation(:,1),1);
        ApproxX = polyval(NormalizeX,PeakPointsLocation(:,2));
        CorrectedPoints = [ApproxX,PeakPointsLocation(:,2)];
    end

    CorrectedMinDist = zeros(length(PeakPointsLocation)-1,1);
    CorrectedPointsTrimmed = zeros(length(PeakPointsLocation)-1,2);
%     CorrectedMinDist = zeros(length(CorrectedPoints)-1,1);
%     CorrectedPointsTrimmed = zeros(length(CorrectedPoints)-1,2);
    for i = 1:length(CorrectedPoints)
        LocationTemp = CorrectedPoints;
        Start = CorrectedPoints(i,:);
        LocationTemp(i,:) = [];
        % Euclidean distance between points
        distances = sqrt(sum(bsxfun(@minus, LocationTemp, Start).^2,2));

        % Row index of nearest point to Start
        k = dsearchn(LocationTemp,Start);
        % Coordinates of nearest point to Start
        ClosePoint = LocationTemp(k,:);
        % Take min distance
        CorrectedMinDist(i,1) = min(distances);
        if ((CorrectedMinDist(i,1)>=(.9*peakLocation)) && (CorrectedMinDist(i,1)<=(1.1*peakLocation)))
            CorrectedPointsTrimmed(i,:) = Start;
        elseif (CorrectedMinDist(i,1)<0.3)
            AvgPoint = [(Start(1,1)+ClosePoint(1,1))/2, (Start(1,2)+ClosePoint(1,2))/2];
            CorrectedPointsTrimmed(i,:) = AvgPoint;
        end
    end
    % Remove zero rows
    CorrectedPointsTrimmed( all(~CorrectedPointsTrimmed,2), : ) = [];
    % Remove Duplicates
    [~,index]=unique(CorrectedPointsTrimmed,'rows');
    CorrectedPointsTrimmed =  CorrectedPointsTrimmed(index,:);
    % Number of tickmarks identified
    TickMarksFound = length(CorrectedPointsTrimmed(:,1));
    
    distances2 = sqrt(sum(bsxfun(@minus, CorrectedPointsTrimmed, CorrectedPointsTrimmed).^2,2));
    
%%%% PLOTTING THE POINTS ON THE IMAGE
    % Plot features for console
    figure(6)
    imshow(img)
    hold on
    scatter(CorrectedPoints(:,1),CorrectedPoints(:,2),'r','filled')
    scatter(CorrectedPointsTrimmed(:,1),CorrectedPointsTrimmed(:,2),'g','filled')
    %line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'g')
    scatter(Location(:,1),Location(:,2),'r','.') 
    hold off

    CorrectedMinDist1 = CorrectedMinDist;
    CorrectedMinDist1 = CorrectedMinDist1((CorrectedMinDist1(:,1)>=(.9*peakLocation)) & (CorrectedMinDist1(:,1)<=(1.1*peakLocation)));
        if isempty(CorrectedMinDist1)
            CorrectedMinDist = harmmean(CorrectedMinDist);
        else
            % Error Catch
            CorrectedMinDist = CorrectedMinDist1;
        end
    [peakDensityC,xiC] = ksdensity(CorrectedMinDist);
    CorrectedPeakLocation = harmmean(CorrectedMinDist); % mm

end