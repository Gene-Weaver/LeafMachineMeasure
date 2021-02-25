% Clean up bboxes, return detectedI to pass along
% 

function [detectedI,bboxOut] = LMM_cleanUpBBoxes(labelsFound,labelWanted,bboxes,scores,labels,img,enlarge,category,LW,false) 
    [dimY, dimX,~] = size(img);
    dim = [dimY, dimX];
    ind = ismember(labelsFound, labelWanted);
    
    % Enlarge prior to cleaning. Will NOT enlarge "text"
    if enlarge
        if category ~= "text" % No Text bbox enlargement
            bboxes = LMM_enlargeBBoxesByCategory(bboxes,category,dim);
            %bboxOut.bboxes = bboxes; % uncomment if this is after checkBBOXintersect() 
        end
    end
    
    [bboxOut] = LMM_checkBBOXintersect(bboxes,scores,labels,ind,img,false);

    bboxes = bboxOut.bboxes;
    labels = bboxOut.labels;
    scores = bboxOut.scores;
    bboxesMax = bboxOut.bboxesMax;
    labelsMax = bboxOut.labelsMax;
    scoresMax = bboxOut.scoresMax;
    
    
   
%     bboxOut.labels = labelsRemainOutSortedOut;
%     bboxOut.scores = scoresRemainOutSortedOut;
%     bboxOut.bboxesMax = bboxesMax;
%     bboxOut.labelsMax = labelsMax;
%     bboxOut.scoresMax = scores_Max;
    
    % Name Labels
    [S1,~] = size(bboxes);
    printLabels = [];
    for ii=1:S1
        printLabels = [printLabels; strjoin([string(labels(ii)),' ', num2str(scores(ii)*100,'%0.2f'), '%'],"")];
    end
    
    % Max labels
    printLabelsMax = strjoin([string(labelsMax),' ', num2str(scoresMax*100,'%0.2f'), '%'],"");

    % Plot bboxes
    % Set color 
    if ismember("barcode",labelWanted), color = 'black'; end
    if ismember("text",labelWanted), color = 'blue'; end
    if ismember("blocks",labelWanted), color = 'green'; end
    if ismember("colorBlock",labelWanted), color = 'cyan'; end
    if ismember("unitMetric",labelWanted), color = 'red'; end
    if ismember("unitINCH",labelWanted), color = 'magenta'; end

    detectedI = insertObjectAnnotation(img,'Rectangle',bboxesMax,cellstr(printLabelsMax),'LineWidth',LW,'TextColor','white','Color',color);
    detectedI = insertObjectAnnotation(detectedI,'Rectangle',bboxes,printLabels,'LineWidth',round((LW/2)),'TextColor','white','Color',color);
    
    
end