function results = LMM_sortDistScanlines(distScanlines)
    if sum(distScanlines.dist_geo) == 0 
        results.MESSAGES = "No_scanline_points_identified";
        results.PRIMARY = [];
        results.PRIMARY_GROUP = [];
        results.SECONDARY = [];
        results.SECONDARY_GROUP = [];
        results.TERTIARY = [];
        results.TERTIARY_GROUP = [];

        results.CONFIDENCE = -1;
    else

        upperBound = 1.03;
        lowerBound = 0.97;

        %distScanlinesOG = distScanlines;
        nK = 6;

        % Remove NaNs
        distScanlines.dist_geo(isnan(distScanlines.dist_geo)) = 0;
        distScanlines.dist_har(isnan(distScanlines.dist_har)) = 0;
        distScanlines.dist_mean(isnan(distScanlines.dist_mean)) = 0;

        % Cluster around ticks found
        %kMeans = kmeans(distScanlines.n_peaks,nK,'MaxIter',1000);
        % The two groups farthest to the right-bottom are the winners
        try
            X = [distScanlines.n_peaks, distScanlines.dist_geo];
            [idx,C] = kmeans(X,nK,'Distance','cityblock','Replicates',1000);
            kmeans1 = 1;
            
        catch
            kmeans1 = 0;
        end
        if kmeans1 ~= 0
        
        
        % figure;
        % plot(X(idx==1,1), X(idx==1,2),'r.','MarkerSize',12)
        % hold on
        % plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
        % plot(X(idx==3,1),X(idx==3,2),'g.','MarkerSize',12)
        % plot(X(idx==4,1),X(idx==4,2),'y.','MarkerSize',12)
        % plot(X(idx==5,1),X(idx==5,2),'m.','MarkerSize',12)
        % plot(X(idx==6,1),X(idx==6,2),'c.','MarkerSize',12)
        % plot(C(:,1),C(:,2),'kx',...
        %      'MarkerSize',15,'LineWidth',3) 
        % legend('Cluster 1','Cluster 2','Centroids',...
        %        'Location','NW')
        % title 'Cluster Assignments and Centroids'
        % hold off

        % Get best group by kmeans centroid
        C2 = C;
        bestGroup = distScanlines(idx == find(C == max(C(:,1)),1),:);

        % Need to check for other geomeans that are near the best group
        % If there is another within 2%, then merge the rows from distscanline
        % If merge, then repeat the process of picking the backupGroup
        %%% BEST GROUP
        bestGroup_geo = geomean(bestGroup.dist_geo);
        bestGroup_geo_upper = bestGroup_geo * 1.02;
        bestGroup_geo_lower = bestGroup_geo * 0.98;
    %     try
    %         bestGroup_geo = geomean(bestGroup.dist_geo);
    %         bestGroup_geo_upper = bestGroup_geo * 1.02;
    %         bestGroup_geo_lower = bestGroup_geo * 0.98;
    % 
    %         if find((C(:,2) <= bestGroup_geo_upper) & (C(:,2) >= bestGroup_geo_lower)) == find(C == max(C(:,1)),1)  % this will usually be true
    %             % Then nothing is similar to the bestgroup
    %         else
    %             indMergeA = find((C(:,2) <= bestGroup_geo_upper) & (C(:,2) >= bestGroup_geo_lower));
    %             indMergeA = indMergeA(~ismember(find((C(:,2) <= bestGroup_geo_upper) & (C(:,2) >= bestGroup_geo_lower))  ,find(C == max(C(:,1)),1)));
    %             if length(indMergeA) > 1
    %                 for i = 1:length(indMerge)
    %                     bestGroup = [bestGroup; distScanlines(idx == indMergeA(i),:)];
    %                 end
    %             else
    %                 bestGroup = [bestGroup; distScanlines(idx == indMergeA,:)];
    %             end
    %         end
    %     catch
    %         bestGroup_geo = mode(bestGroup.dist_geo);  % ONLY DIFFERENCE
    %         bestGroup_geo_upper = bestGroup_geo * 1.02;
    %         bestGroup_geo_lower = bestGroup_geo * 0.98;
    % 
    %         if find((C(:,2) <= bestGroup_geo_upper) & (C(:,2) >= bestGroup_geo_lower)) == find(C == max(C(:,1)),1)  % this will usually be true
    %             % Then nothing is similar to the bestgroup
    %         else
    %             indMergeA = find((C(:,2) <= bestGroup_geo_upper) & (C(:,2) >= bestGroup_geo_lower));
    %             indMergeA = indMergeA(~ismember(find((C(:,2) <= bestGroup_geo_upper) & (C(:,2) >= bestGroup_geo_lower))  ,find(C == max(C(:,1)),1)));
    %             if length(indMergeA) > 1
    %                 for i = 1:length(indMerge)
    %                     bestGroup = [bestGroup; distScanlines(idx == indMergeA(i),:)];
    %                 end
    %             else
    %                 bestGroup = [bestGroup; distScanlines(idx == indMergeA,:)];
    %             end
    %         end 
    %     end

        [~,ind] = min(abs(bestGroup.dist_geo - bestGroup_geo));
        bestGroup_row = bestGroup(ind,:);

        % Find 2nd best
        C2(find(C2 == max(C2(:,1)),1),:) = [];
        C2(find(C2 == max(C2(:,1)),1));
        indBackup = find(C == C2(find(C2 == max(C2(:,1)),1)),1);

        % Get backup group
        backUpGroup = distScanlines(idx == indBackup,:);

        %%% BACKUP GROUP
        backUpGroup_geo = geomean(backUpGroup.dist_geo);
        backUpGroup_geo_upper = backUpGroup_geo * upperBound;
        backUpGroup_geo_lower = backUpGroup_geo * lowerBound;

        if find((C2(:,2) <= backUpGroup_geo_upper) & (C2(:,2) >= backUpGroup_geo_lower)) == find(C2 == max(C2(:,1)),1)  % this will usually be true
            % Then nothing is similar to the bestgroup

        elseif length(find((C2(:,2) <= backUpGroup_geo_upper) & (C2(:,2) >= backUpGroup_geo_lower))) > 1   %ismember(find((C2(:,2) <= backUpGroup_geo_upper) & (C2(:,2) >= backUpGroup_geo_lower)),     find(C2 == max(C2(:,1)),1))
            indMerge = find((C2(:,2) <= backUpGroup_geo_upper) & (C2(:,2) >= backUpGroup_geo_lower));
            indMerge = indMerge(~ismember(find((C2(:,2) <= backUpGroup_geo_upper) & (C2(:,2) >= backUpGroup_geo_lower))  ,find(C2 == max(C2(:,1)),1)));
            if length(indMerge) > 1
                for i = 1:length(indMerge)
                    backUpGroup = [backUpGroup; distScanlines(idx == indMerge(i),:)];
                end
            else
                backUpGroup = [backUpGroup; distScanlines(idx == indMerge,:)];    
            end
        end

        %%% BACKUP-GROUP KMEANS
        % Goal here is to find the 2nd and third best groups,
        % checking each against the bestGroup, and between each other.

        % try a 2-kmeans agian for the CHECKS
        try
            X2 = [backUpGroup.n_peaks, backUpGroup.dist_geo];
            [idx2,CB] = kmeans(X2,2,'Distance','cityblock','Replicates',1000);

            CHECK1_Group = backUpGroup(idx2 == 1,:);
            CHECK2_Group = backUpGroup(idx2 == 2,:);
        catch
            CHECK1_Group = backUpGroup;
            CHECK2_Group = backUpGroup;
        end


        %backUpGroup_geo = geomean(backUpGroup.dist_geo);
        %[~,ind2] = min(abs(backUpGroup.dist_geo - backUpGroup_geo));

        %backUpGroup_row = backUpGroup(ind2,:);

        CHECK1_Group_geo = geomean(CHECK1_Group.dist_geo);
        CHECK2_Group_geo = geomean(CHECK2_Group.dist_geo);

        [~,indC1] = min(abs(CHECK1_Group.dist_geo - CHECK1_Group_geo));
        [~,indC2] = min(abs(CHECK2_Group.dist_geo - CHECK2_Group_geo));

        CHECK1_Group_Best_Row = CHECK1_Group(indC1,:);
        CHECK2_Group_Best_Row = CHECK2_Group(indC2,:);

        % These are the best values from each group to compare to the 
        CHECK1 = CHECK1_Group_Best_Row.dist_geo;
        CHECK2 = CHECK2_Group_Best_Row.dist_geo;


        % See if the CHECKS are equal
        % LMM_checkMetricConversion(A, B,  nB, nA);
        % A --> bigger number
        % nB is nPeaks of the *little* number 
        %
        % If the swap value == 1, then A was smaller than B

        if ((CHECK1 / CHECK2 >= lowerBound) && (CHECK1 / CHECK2 <= upperBound))
            [swap_VAL_CHECK_EQ,VAL_CHECK_EQ] = LMM_checkMetricConversion(CHECK1, CHECK2,  CHECK2_Group_Best_Row.n_peaks, []);
        else % The check values are not equal and provide no additional value
            swap_VAL_CHECK_EQ = 1;
            VAL_CHECK_EQ = "Backup_Values_Not_Equal"; 
        end

        % Big number first
        % Check each CHECK against the bestGroup value
        [swap_VAL_CHECK_1toBest,VAL_CHECK_1toBest] = LMM_checkMetricConversion(CHECK1, bestGroup_row.dist_geo,  bestGroup_row.n_peaks, CHECK1_Group_Best_Row.n_peaks);

        [swap_VAL_CHECK_2toBest,VAL_CHECK_2toBest] = LMM_checkMetricConversion(CHECK2, bestGroup_row.dist_geo,  bestGroup_row.n_peaks, CHECK2_Group_Best_Row.n_peaks);

        % Big number first
        % Check each CHECK against the bestGroup value
        [swap_VAL_CHECK_1to2,VAL_CHECK_1to2] = LMM_checkMetricConversion(CHECK1, CHECK2,  CHECK2_Group_Best_Row.n_peaks, CHECK1_Group_Best_Row.n_peaks);

        %%% Ideally, one or both of convFactor1/2 will give an output
        %%% If they are both "NA" then two things are possible
        %%%      1. Either the bestGroup is wrong
        %%%                   OR
        %%%      2. There is no validation
        %%%              If this is true, then we'll accept the one with the lowest var, highest nPeaks, that makes sense in context
        %%%              i.e. 

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % These are the rows to return
        %     bestGroup_row
        %     CHECK1_Group_Best_Row 
        %     CHECK2_Group_Best_Row
        %   
        % These are groups of rows to return
        %     bestGroup
        %     CHECK1_Group 
        %     CHECK2_Group
        %
        % These the validation checks
        %     VAL_CHECK_EQ
        %     VAL_CHECK_1toBest
        %     VAL_CHECK_2toBest
        %     VAL_CHECK_1to2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%


        results = parseValidation(VAL_CHECK_EQ,VAL_CHECK_1toBest,VAL_CHECK_2toBest,VAL_CHECK_1to2,...
                                  swap_VAL_CHECK_EQ,swap_VAL_CHECK_1toBest,swap_VAL_CHECK_2toBest,swap_VAL_CHECK_1to2);


        CONFIDENCE = results.valScore;
        % Start with the triple case
        if (results.useBest && results.useCheck1 && results.useCheck2)
            % Assign Primary 
            if results.valSmall == "best"
                PRIMARY = bestGroup_row;
                PRIMARY_GROUP = bestGroup;
            elseif results.valSmall == "check1"
                PRIMARY = CHECK1_Group_Best_Row;
                PRIMARY_GROUP = CHECK1_Group;
            elseif results.valSmall == "check2"
                PRIMARY = CHECK2_Group_Best_Row;
                PRIMARY_GROUP = CHECK2_Group;
            end

            % Assign Secondary 
            if results.valMid == "best"
                SECONDARY = bestGroup_row;
                SECONDARY_GROUP = bestGroup;
            elseif results.valMid == "check1"
                SECONDARY = CHECK1_Group_Best_Row;
                SECONDARY_GROUP = CHECK1_Group;
            elseif results.valMid == "check2"
                SECONDARY = CHECK2_Group_Best_Row;
                SECONDARY_GROUP = CHECK2_Group;
            end

            % Assign Tertiary 
            if results.valBig == "best"
                TERTIARY = bestGroup_row;
                TERTIARY_GROUP = bestGroup;
            elseif results.valBig == "check1"
                TERTIARY = CHECK1_Group_Best_Row;
                TERTIARY_GROUP = CHECK1_Group;
            elseif results.valBig == "check2"
                TERTIARY = CHECK2_Group_Best_Row;
                TERTIARY_GROUP = CHECK2_Group;
            end


        % Case where all are "NA", single validation, lots of uncertainty
        % OR when all three are the same, can tell by confidence number
        elseif (results.useBest && (~results.useCheck1) && (~results.useCheck2))
            % Assign Primary 
            if results.valSmall == "best"
                PRIMARY = bestGroup_row;
                PRIMARY_GROUP = bestGroup;
            elseif results.valSmall == "check1"
                PRIMARY = CHECK1_Group_Best_Row;
                PRIMARY_GROUP = CHECK1_Group;
            elseif results.valSmall == "check2"
                PRIMARY = CHECK2_Group_Best_Row;
                PRIMARY_GROUP = CHECK2_Group;
            end
            SECONDARY = [];
            SECONDARY_GROUP = [];
            TERTIARY = [];
            TERTIARY_GROUP = [];


        % Majority of cases, cross val, or just 2 remaining
        else
            % Assign Primary 
            if results.valSmall == "best"
                PRIMARY = bestGroup_row;
                PRIMARY_GROUP = bestGroup;
            elseif results.valSmall == "check1"
                PRIMARY = CHECK1_Group_Best_Row;
                PRIMARY_GROUP = CHECK1_Group;
            elseif results.valSmall == "check2"
                PRIMARY = CHECK2_Group_Best_Row;
                PRIMARY_GROUP = CHECK2_Group;
            end

            % Assign Secondary 
            if results.valBig == "best"
                SECONDARY = bestGroup_row;
                SECONDARY_GROUP = bestGroup;
            elseif results.valBig == "check1"
                SECONDARY = CHECK1_Group_Best_Row;
                SECONDARY_GROUP = CHECK1_Group;
            elseif results.valBig == "check2"
                SECONDARY = CHECK2_Group_Best_Row;
                SECONDARY_GROUP = CHECK2_Group;
            end
            TERTIARY =[];
            TERTIARY_GROUP = [];
        end



        % Report results
        results.MESSAGES = strcat("|A:",VAL_CHECK_EQ,"|B:",VAL_CHECK_1toBest,"|C:",VAL_CHECK_2toBest,"|D:",VAL_CHECK_1to2);
        results.PRIMARY = PRIMARY;
        results.PRIMARY_GROUP = PRIMARY_GROUP;
        results.SECONDARY = SECONDARY;
        results.SECONDARY_GROUP = SECONDARY_GROUP;
        results.TERTIARY = TERTIARY;
        results.TERTIARY_GROUP = TERTIARY_GROUP;

        results.CONFIDENCE = CONFIDENCE;
        %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\black_Dual__1790__1.jpg'); %white ticks, dual % ~13 & 21    swap=0 "1mm_to_1_16" *PASS*
        %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\black_Metric__454__2.jpg'); % white ticks, single % ~11.8   swap=0 "equal_mm" *PASS*
        %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\blackSplit_Dual__1980__1.jpg'); % white ticks dual   10.2mm 17,1/16   swap=0 "equal_mm" & "1mm_to_1_16" *PASS!!!!!*         
        %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\blackStrip_MM__668__2.jpg'); % white ticks, single  13mm "equal_mm" 
        %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\clear_Dual__1171__2.jpg'); % black ticks, dual, both mm     works SUPER %13mm "equal_mm"x3
        %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\clear_Dual__2152__2.jpg'); % black ticks, dual 1/2 mm and mm white_Metric__2095__2    8 for 0.5mm and 16 for 1mm
        %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\white_Metric__2095__2.jpg'); % black ticks, single 1,1/2,1/4 cm ?!?! 9px
        %for the 1/4cm... stupid ruler ***FAIL*** got measure right, but the ruler is in 4ths even though its metric
        %img = imread('A:\Image_Database\DwC_10RandImg__Rulers_Cropped_TICKMARKS\whiteComplex10CM_Metric__1506__2.jpg'); % black ticks, mm and blocks 12.9
        %*PASS* BUT return all "NA" and no convFactor3
        else
            results.MESSAGES = "No_kmeans_testing_or_crossval";
            % Report only the best single row
            tempPrimary = distScanlines(distScanlines.w_var == min(distScanlines.w_var),:);
            results.PRIMARY = tempPrimary(1,:);
            results.PRIMARY_GROUP = distScanlines;
            results.SECONDARY = [];
            results.SECONDARY_GROUP = [];
            results.TERTIARY = [];
            results.TERTIARY_GROUP = [];

            results.CONFIDENCE = 0;
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These are the rows to return
%     bestGroup_row
%     CHECK1_Group_Best_Row 
%     CHECK2_Group_Best_Row
%   
% These are groups of rows to return
%     bestGroup
%     CHECK1_Group 
%     CHECK2_Group
%
% These the validation checks
%     VAL_CHECK_EQ
%     VAL_CHECK_1toBest
%     VAL_CHECK_2toBest
%     VAL_CHECK_1to2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If the swaps == 1, then the second value was bigger
function results = parseValidation(VAL_CHECK_EQ,VAL_CHECK_1toBest,VAL_CHECK_2toBest,VAL_CHECK_1to2,...
    swap_VAL_CHECK_EQ,swap_VAL_CHECK_1toBest,swap_VAL_CHECK_2toBest,swap_VAL_CHECK_1to2)

    if ((VAL_CHECK_1toBest == "NA") && (VAL_CHECK_2toBest == "NA") && (VAL_CHECK_1to2 == "NA"))
        useBest = 0;
        useCheck1 = 0;
        useCheck2 = 0;
    else
        useBest = 1;
        useCheck1 = 1;
        useCheck2 = 1;
    end
    
%     cSmall = "NA";
%     cMid = "NA";
%     cBig = "NA";
    valSmall = "NA";
    valBig = "NA";
    valMid = "NA";
    
    valScore = 0;

    % if Check1 and Check2 are the same, then ignore check2 (are these always the same?)
    if VAL_CHECK_EQ == "equal"
        useCheck2 = 0;
        valScore = valScore + 1;
    end
    %if VAL_CHECK_1to2 == "equal"
    %    useCheck2 = 0;
    %end
    
    % Check for equality with best
    if VAL_CHECK_1toBest == "equal"
        useCheck1 = 0;
        valScore = valScore + 1;
    end
    if VAL_CHECK_2toBest == "equal"
        useCheck2 = 0;
        valScore = valScore + 1;
    end
    
    % Check for "NA"s
    if VAL_CHECK_1toBest == "NA"
        useCheck1 = 0;
    end
    if VAL_CHECK_2toBest == "NA"
        useCheck2 = 0;
    end
    
    % *CASE* the case where VAL_CHECK_1to2 may = "equal" or ~"NA" and 1toB and 2toB are not "equal" or "NA"
    % This is the only path where the best would be ignored and the checks would win out
    if ((VAL_CHECK_1to2 ~= "NA") && ((VAL_CHECK_1toBest == "NA")||(VAL_CHECK_1toBest == "equal")) && ((VAL_CHECK_2toBest == "NA")||(VAL_CHECK_2toBest == "equal"))) 
        useBest = 0;
        useCheck1 = 1; % reactivate both, if they're "equal" then we'll deal with it
        useCheck2 = 1;
        valScore = valScore + 10; % plus 10 because it's a significant thing to notice, not because it's actually *that* good
    end
        
    
    % Compare useBest and useChecks
    % If success, then the smaller one *should be the mm*, unless the ruler has stupid fractional proportions like 1cm and 1/4th inches
    % Or unless the smaller one is 1/2 the large (0.5mm and 1mmm. for example)
    % check1
    if (useBest && useCheck1 && useCheck2)
        valScore = valScore + 3;
        
        if (swap_VAL_CHECK_1toBest && swap_VAL_CHECK_2toBest && swap_VAL_CHECK_1to2)
            valBig = "best";
            valMid = "check2";
            valSmall = "check1";
        elseif (swap_VAL_CHECK_1toBest && swap_VAL_CHECK_2toBest && (~swap_VAL_CHECK_1to2))
            valBig = "best";
            valMid = "check1";
            valSmall = "check2";
            
        elseif ((~swap_VAL_CHECK_1toBest) && swap_VAL_CHECK_2toBest && (~swap_VAL_CHECK_1to2))
            valBig = "check1";
            valMid = "best";
            valSmall = "check2";
        elseif ((~swap_VAL_CHECK_1toBest) && (~swap_VAL_CHECK_2toBest) && (~swap_VAL_CHECK_1to2))
            valBig = "check1";
            valMid = "check2";
            valSmall = "best";
            
        elseif ((~swap_VAL_CHECK_1toBest) && (~swap_VAL_CHECK_2toBest) && swap_VAL_CHECK_1to2)
            valBig = "check2";
            valMid = "check1";
            valSmall = "best";
        elseif (swap_VAL_CHECK_1toBest && (~swap_VAL_CHECK_2toBest) && swap_VAL_CHECK_1to2)
            valBig = "check2";
            valMid = "best";
            valSmall = "check1";
        end
            
            
    elseif (useBest && useCheck1 && (~useCheck2)) % They are conversions, but NOT equal
        if swap_VAL_CHECK_1toBest % Best > Check1
            if ((VAL_CHECK_1toBest ~= "small_tick_half_of_large") || (VAL_CHECK_1toBest ~= "1_2mm_to_1mm"))
                valBig = "best";
                valSmall = "check1";
                valScore = valScore + 1;
            else
                valBig = "check1"; % In this case, we are reporting valBid to be the *small* value bc it's likely the mm.
                valSmall = "best"; % This path is RARE
                valScore = valScore + 1;
            end
        else % Check1 > Best
            if ((VAL_CHECK_1toBest ~= "small_tick_half_of_large") || (VAL_CHECK_1toBest ~= "1_2mm_to_1mm"))
                valBig = "check1";
                valSmall = "best";
                valScore = valScore + 1;
            else
                valBig = "best"; % In this case, we are reporting valBid to be the *small* value bc it's likely the mm.
                valSmall = "check1"; % This path is RARE
                valScore = valScore + 1;
            end
        end
     
        
    % check2  
    elseif (useBest && useCheck2 && (~useCheck1)) % They are conversions, but NOT equal
        if swap_VAL_CHECK_2toBest % Best > Check2
            if ((VAL_CHECK_2toBest ~= "small_tick_half_of_large") || (VAL_CHECK_2toBest ~= "1_2mm_to_1mm"))
                valBig = "best";
                valSmall = "check2";
                valScore = valScore + 1;
            else
                valBig = "check2"; % In this case, we are reporting valBid to be the *small* value bc it's likely the mm.
                valSmall = "best"; % This path is RARE
                valScore = valScore + 1;
            end
        else % Check1 > Best
            if ((VAL_CHECK_2toBest ~= "small_tick_half_of_large") || (VAL_CHECK_2toBest ~= "1_2mm_to_1mm"))
                valBig = "check2";
                valSmall = "best";
                valScore = valScore + 1;
            else
                valBig = "best"; % In this case, we are reporting valBid to be the *small* value bc it's likely the mm.
                valSmall = "check2"; % This path is RARE
                valScore = valScore + 1;
            end
        end
        
        
    % Case where either both check1 and 2 are equivalent to best, or best is the only one left    
    elseif (useBest  && (~useCheck1) && (~useCheck2))
        valBig = "NA";
        valSmall = "best";
        % valScore = valScore + 0; % no adding to score, if in this loop from "equal" then they already added the score
        
        
        
    % This only happens if *CASE*, same as upper loop, but swap best for C1 and C2
    elseif ((~useBest)  && useCheck1 && useCheck2) 
        if swap_VAL_CHECK_1to2 % Check2 > Check1
            if ((VAL_CHECK_1to2 ~= "small_tick_half_of_large") || (VAL_CHECK_1to2 ~= "1_2mm_to_1mm"))
                valBig = "check2";
                valSmall = "check1";
                valScore = valScore + 1;
            else
                valBig = "check1"; % In this case, we are reporting valBid to be the *small* value bc it's likely the mm.
                valSmall = "check2"; % This path is RARE
                valScore = valScore + 1;
            end
        else % Check1 > Check2
            if ((VAL_CHECK_1to2 ~= "small_tick_half_of_large") || (VAL_CHECK_1to2 ~= "1_2mm_to_1mm"))
                valBig = "check1";
                valSmall = "check2";
                valScore = valScore + 1;
            else
                valBig = "check2"; % In this case, we are reporting valBid to be the *small* value bc it's likely the mm.
                valSmall = "check1"; % This path is RARE
                valScore = valScore + 1;
            end
        end
        
    end
    

    % QC check
    vals = [valSmall,valMid,valBig];
    if ((useBest == 0) && (ismember("best",vals)))
        ME = MException('MyComponent:noSuchVariable','This --> %s <-- does not belong',"best");
        throw(ME);
    end
    if ((useCheck1 == 0) && (ismember("check1",vals)))
        ME = MException('MyComponent:noSuchVariable','This --> %s <-- does not belong',"check1");
        throw(ME);
    end
    if ((useCheck2 == 0) && (ismember("check2",vals)))
        ME = MException('MyComponent:noSuchVariable','This --> %s <-- does not belong',"check2");
        throw(ME);
    end
        

%     valMessage = [cSmall,cMid,cBig];
%     % Report conversion messages 
%     if ismember("best",vals)
%         if useCheck1
%             m = VAL_CHECK_1toBest;
%         elseif useCheck2
%             m = VAL_CHECK_2toBest;
%         else
%             m = "NA";
%         end
%         if contains(m,"mm")
%             valMessage(vals=="best") = "mm";
%         elseif contains(m,"cm")
%             valMessage(vals=="best") = "cm";
%         else
%             
%         end
%         
%         
%     end
%             
    
    
    % If at the end, none are 1, then make best 1 and the valScore = 0;
    if ((useBest == 0) && (useCheck1 == 0) && (useCheck2 == 0))
        useBest = 1;
        valScore = 0;
        valSmall = "best";
    end
    
%     valMessage =;
%     results.valMessage = valMessage;
    results.useBest = useBest;
    results.useCheck1 = useCheck1;
    results.useCheck2 = useCheck2;
    results.valSmall = valSmall;
    results.valBig = valBig;
    results.valMid = valMid;
    
    results.valScore = valScore;

end

