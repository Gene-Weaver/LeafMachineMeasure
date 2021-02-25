% Check the bounding boxes for intersections *within* the same class

function [cleaned] = LMM_checkBBOXintersect(bboxes,scores,labels,ind,img,check)

    bboxes = bboxes(ind,:);
    scores = scores(ind,:);
    labels = labels(ind,:);

    % Find high score 
    [scores_Max, ind_Max ] = maxk(scores,1);
    bboxesMax = bboxes(ind_Max,:);
    labelsMax = labels(ind_Max,:);
    
    % Setup
    bboxesRemain = bboxes;
    labelsRemain = labels;
    scoresRemain = scores;
    bboxesRemainOut = [];
    labelsRemainOut = [];
    scoresRemainOut = [];
    count = 1;
    
    while count > 0 
        count = 0;
        [nBoxes,~] = size(bboxes);
        
        mergedBBoxes = [];
        mergedLabels = [];
        mergedScores = [];
        
        for i = 1:nBoxes-1
            [nBoxes,~] = size(bboxes);
        
            select = 1:1:nBoxes;
            select = select(:,select ~= i);

            first = bboxes(i,:);
            firstL = labels(i);
            firstS = scores(i);

            others = bboxes(select,:);
            othersL = labels(select,:);
            othersS = scores(select,:);
            
            [nBoxes2,~] = size(others);
            for j = 1:nBoxes2
                compare = others(j,:);
                compareL = othersL(j);
                compareS = othersS(j);
                
                area = rectint(first,compare);
                if area > 0
                    %%%%%%%%% Merge bounding boxes
                    new = [min([first(1),compare(1)]) min([first(2),compare(2)]) min(first(3),compare(3))+(abs(first(1)-compare(1))) max([first(4),compare(4)])+(abs(first(2)-compare(2)))];
                    mergedBBoxes = [mergedBBoxes; new];
                    
                    scoreMat = [firstS,compareS];
                    labelMat = [firstL,compareL];
                    imax = find(scoreMat == max(scoreMat(:)));
                    if length(imax) > 1, imax = imax(1); end
                    
                    newS = scoreMat(imax);
                    newL = labelMat(imax);
                     
                    mergedLabels = [mergedLabels; newL];
                    mergedScores = [mergedScores; newS];

                    bboxesRemain(i,:) = [0 0 0 0];
                    bboxesRemain(select(j),:) = [0 0 0 0];
                    labelsRemain(i,:) = 'NA';
                    labelsRemain(select(j),:) = 'NA';
                    scoresRemain(i,:) = 0;
                    scoresRemain(select(j),:) = 0;

                    bboxes(i,:) = [0 0 0 0];
                    bboxes(select(j),:) = [0 0 0 0];
                    labels(i,:) = 'NA';
                    labels(select(j),:) = 'NA';
                    scores(i,:) = 0;
                    scores(select(j),:) = 0;

                    count = count + 1;
                elseif area == 0
                    
                end
            end
            
        end
        bboxesRemain = bboxesRemain(any(bboxesRemain,2),:);

        if ~isempty(mergedBBoxes), bboxesRemain = [bboxesRemain; mergedBBoxes]; end%**** add back the new merge box
        if ~isempty(bboxesRemain), bboxesRemainOut = [bboxesRemainOut;bboxesRemain]; end
        
        labelsRemain(labelsRemain == 'NA') = [];
        if ~isempty(mergedLabels)%**** add back the new merge box
            [S1, S2] = size(mergedLabels);
            if S2 > S1
                mergedLabels = mergedLabels';
            end
            %labelsRemain = labelsRemain'; 
            labelsRemain = [labelsRemain; mergedLabels]; 
        end%**** add back the new merge box
        if ~isempty(labelsRemain)
            [S1, S2] = size(labelsRemain);
            if S2 > S1
                labelsRemain = labelsRemain';
            end
            %labelsRemain = labelsRemain'; 
            labelsRemainOut = [labelsRemainOut; labelsRemain]; 
        end
        
        scoresRemain(scoresRemain == 0) = [];
        if ~isempty(mergedScores)%**** add back the new merge box
            [S1, S2] = size(mergedScores);
            if S2 > S1
                mergedScores = mergedScores';
            end
            scoresRemain = [scoresRemain; mergedScores]; 
        end%**** add back the new merge box
        if ~isempty(scoresRemain)
            [S1, S2] = size(scoresRemain);
            if S2 > S1
                scoresRemain = scoresRemain';
            end
            scoresRemainOut = [scoresRemainOut; scoresRemain]; 
        end
        
        % Recursive bit
        %bboxes = mergedBBoxes;%****
        %bboxesRemain = bboxes;
        bboxes = bboxesRemain;
        %labels = mergedLabels;%****
        %labelsRemain = labels;
        labels = labelsRemain;
        %scores = mergedScores;%****
        %scoresRemain = scores;
        scores = scoresRemain;
    end
    
    % Contain the labels scores bboxes: labelsRemainOut scoresRemainOut bboxesRemainOut

    % Remove any nested boxes
    [nBoxes,~] = size(bboxesRemainOut);
    areas = [];
    for i = 1:nBoxes
        areas = [areas; prod(bboxesRemainOut(i,3:4))];
    end
    
    [~,Sorti] = sort(areas,'descend');
    bboxesRemainOutSorted = bboxesRemainOut(Sorti,:);
    bboxesRemainOutSortedOut = bboxesRemainOutSorted;
    
    labelsRemainOutSorted = labelsRemainOut(Sorti,:);
    labelsRemainOutSortedOut = labelsRemainOutSorted;
    
    scoresRemainOutSorted = scoresRemainOut(Sorti,:);
    scoresRemainOutSortedOut = scoresRemainOutSorted;
    
    for i = 1:nBoxes-1
        big = bboxesRemainOutSorted(i,:);
        bigS = scoresRemainOutSorted(i);
        bigL = labelsRemainOutSorted(i);
        
        others = bboxesRemainOutSorted(i+1:nBoxes,:);
        othersS = scoresRemainOutSorted(i+1:nBoxes);
        othersL = labelsRemainOutSorted(i+1:nBoxes);
        [nBoxes2,~] = size(others);
        
        for j = 1:nBoxes2
            little = others(j,:);
            littleS = othersS(j);
            littleL = othersL(j);
            
            overlapRatio = bboxOverlapRatio(big,little);
            if overlapRatio ~= 0
                bboxesRemainOutSortedOut(i+j,:) = [0 0 0 0];
                labelsRemainOutSortedOut(i+j) = 'NA';
                scoresRemainOutSortedOut(i+j) = 0;
            end
        end
    end
    
    if check == true
        detectedI = insertObjectAnnotation(img,'Rectangle',bboxesRemainOutSortedOut,"SOLO",'LineWidth',10,'TextColor','white','Color',{'green'});
        figure(20)
        imshow(detectedI)
    end
    
    bboxesRemainOutSortedOut = bboxesRemainOutSortedOut(any(bboxesRemainOutSortedOut,2),:);
    labelsRemainOutSortedOut(labelsRemainOutSortedOut == 'NA') = [];
    scoresRemainOutSortedOut(scoresRemainOutSortedOut == 0) = [];
    
    cleaned.bboxes = bboxesRemainOutSortedOut;
    cleaned.labels = labelsRemainOutSortedOut;
    cleaned.scores = scoresRemainOutSortedOut;
    cleaned.bboxesMax = bboxesMax;
    cleaned.labelsMax = labelsMax;
    cleaned.scoresMax = scores_Max;
    
end

