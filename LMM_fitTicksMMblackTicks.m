function [dist,plotPoints] = LMM_fitTicksMMblackTicks(img,binOpt,boxPointsINCROPtf,boxPoints,peakMin,distHeaders,NAME,SCAN,yPosOverall,yPosScan)
    distData = cell(1,length(distHeaders));
    dist = cell2table(distData);
    dist.Properties.VariableNames = distHeaders;
    
    % The ticks need to be white(1) for calculations
    % Calc with ticks as black = img     (0)
    % Calc with ticks as white = img_com (1)
    if binOpt == "gray"
        img_com = img;
    else
        %imshow(img)
        img_com = imcomplement(img);
        %imshow(img_com)
    end
    % Find Harris points that are within the crop
    HpointsINCROP = boxPoints.Location(boxPointsINCROPtf,:);
    
    % X-axis for plotting, QC
    x = 1:length(img_com);
    
    % Sum the scanlines
    data = sum(img_com,1);
    
%     % Plot the scanlines
%     figure(1);  
%     plot(data)
    
    % Find local maxima
    Lmax = islocalmax(data, 'FlatSelection', 'center');
    i_Lmax = x(Lmax);
     
    %%% Show that the peaks are correct
%     figure(2);  
%     plot(x,data,x(Lmax),data(Lmax),'r*')
%     %Plot an overlay of the points on the image
%     figure(3);    
%     imshow(img_com)
%     hold on 
%     scatter(i_Lmax,repmat(yPosScan,1,length(i_Lmax)),'g.')
%     scatter(HpointsINCROP(:,1),repmat(yPosScan,1,length(HpointsINCROP(:,1))),'r.')
%     hold off
     
%     figure(4);    
%     imshow(img_bausch)
%     hold on 
% %     scatter(i_Lmax,repmat(yPosOverall,1,length(i_Lmax)),'g.')
%     scatter(HpointsINCROP(:,1),HpointsINCROP(:,2),'r.')
%     coefficients = polyfit(HpointsINCROP(:,1), HpointsINCROP(:,2), 1);
%     yFit = polyval(coefficients , x);
%     plot(x, yFit, 'r-', 'LineWidth', 2);
%     scatter(i_Lmax,repmat(yPosOverall,1,length(i_Lmax)),'g.')
%     hold off
    

    % ********** TRY TO MATCH PLOTTING POINTS WITH REALITY
%     [Hpoints_dif,I] = pdist2(HpointsINCROP(:,1),HpointsINCROP(:,2),'euclidean','Smallest',l);
%     Hpoints_dif = Hpoints_dif';
%     I = I';
    % Calc Variance Harris Pts
    Hpoints_dif = diff(HpointsINCROP(:,1));
    Hpoints_dif = Hpoints_dif(Hpoints_dif >= 1);
    %%%%%%%%%%%% Line below grabs values within +- 20% of median
    Hpoints_dif = Hpoints_dif(Hpoints_dif >= median(Hpoints_dif)*0.8 & Hpoints_dif <= median(Hpoints_dif)*1.2);
    Hpoints_dist_geo = geomean(Hpoints_dif); 
    Hpoints_sd = std(Hpoints_dif);
    Hpoints_geo_up = Hpoints_dist_geo + Hpoints_sd;
    Hpoints_geo_low = Hpoints_dist_geo - Hpoints_sd;
    Hpoints_dif_filtered = Hpoints_dif(Hpoints_dif >= Hpoints_geo_low & Hpoints_dif <= Hpoints_geo_up);
%     I = ismember(Hpoints_dif,Hpoints_dif_filtered);
%     III = diff(HpointsINCROP(I,1));
    if ~isempty(Hpoints_dif_filtered)
        Hpoints_v = var(Hpoints_dif_filtered);
        Hpoints_n_peaks = length(Hpoints_dif_filtered);
        Hpoints_weighted_variance = Hpoints_v / Hpoints_n_peaks;
    else
        Hpoints_v = 0; 
        Hpoints_n_peaks = 0;
        Hpoints_weighted_variance = 0;
    end
    
    % Calc Variance
    dif = diff(i_Lmax);
    %%%%%%%%%%%% Line below grabs values within +- 20% of median
    dif = dif(dif >= median(dif)*0.8 & dif <= median(dif)*1.2);
    dist_geo = geomean(dif); 
    sd = std(dif);
    geo_up = dist_geo + 2*sd;
    geo_low = dist_geo - 2*sd;
    dif_filtered = dif(dif >= geo_low & dif <= geo_up);
    if ~isempty(dif_filtered)
        v = var(dif_filtered);
        reg_n_peaks = length(dif_filtered);
        reg_weighted_variance = v / reg_n_peaks;
    else
        v = 0;
        reg_n_peaks = 0;
        reg_weighted_variance = 0;
    end
    
    if (( Hpoints_weighted_variance == 0) || (reg_weighted_variance < Hpoints_weighted_variance))
        % Calc Distances, geo mean is ideal
        dist_mean = mean(dif_filtered);
        dist_har = harmmean(dif_filtered);
        dist_geo = geomean(dif_filtered); %closest on good data

        n_peaks = reg_n_peaks;
        weighted_variance = reg_weighted_variance;
        
        plotPoints = [i_Lmax;repmat(yPosOverall,1,length(i_Lmax))];
        dist_method = "Peaks";
    else
        % Calc Distances, geo mean is ideal
        dist_mean = mean(Hpoints_dif_filtered);
        dist_har = harmmean(Hpoints_dif_filtered);
        dist_geo = geomean(Hpoints_dif_filtered); %closest on good data

        n_peaks = Hpoints_n_peaks;
        weighted_variance = Hpoints_weighted_variance;

        plotPoints = [HpointsINCROP(:,1)';repmat(yPosScan,1,length(HpointsINCROP(:,1)))];
        dist_method = "Harris";
    end
    

    % Export
    dist.name = NAME;
    dist.scan = SCAN;
    dist.method = dist_method;
    dist.dist_mean = dist_mean;
    dist.dist_har = dist_har;
    dist.dist_geo = dist_geo;
    dist.variance = v;
    dist.w_var = weighted_variance;
    dist.n_peaks=  n_peaks;
    dist.yPosition = yPosOverall;
    
    
    
    % Main Peaks using findpeaks() *** Does not work as well
%     [peaks, location, peakWidth, peakProm] = findpeaks(data,'MinPeakProminence',yPosScan*2);% yPosScan because it's 50% the height of the scan 
%     [mainPeaks, locationMain] = find( peaks >= peakMin);
%     i_locationMain = location(locationMain);
%     figure(4);    
%     imshow(img_com)
%     hold on 
%     scatter(i_locationMain,repmat(yPosScan,1,length(i_locationMain)),'r.')
%     hold off
%     
%     dist_mean = mean(diff(i_locationMain));
%     dist_har = harmmean(diff(i_locationMain));
%     dist_geo = geomean(diff(i_locationMain)); %closest on good data

        % THIS WORKS SO WELL!!!!!! for the perfect ruler that is
    % Do this with the really old version and add in variance stuff for the
    % not so perfect situations
%     boxPoints = detectMSERFeatures(img);%,'MinQuality', 0.1);
%     [boxFeatures, boxPoints] = extractFeatures(img, boxPoints);
    
    %dist_SURF = fitTicks_SURFpoints(boxPoints) % ######## finish this ######################
end