% Nested function inside correctRulerAngle_Preprocess()
% Removes text from the gray image so it doesn't mess with the tick mark
% function 

function imgBW = LMM_removeWords(imgBW,PF)
    % Remove largest 3 ogjects, should let the rest of the code ignore the
    % tick marks
    % imshow(imgBW)
    numWhitePixels = sum(imgBW(:));
    numBlackPixels = sum(~imgBW(:));
    if numWhitePixels>= numBlackPixels, imgBW = imcomplement(imgBW);end
    imgBW = bwareaopen(imgBW,19);
    
    largestObjRemoved = imbinarize(imgBW.*(~bwareafilt(imgBW,3)));
    if PF==1, figure(5),imshow(largestObjRemoved);end
    
    % Bounding Boxes
    s = regionprops(largestObjRemoved,'BoundingBox');
    roi = vertcat(s(:).BoundingBox);

    % Run OCR only on ROI
    results = ocr(largestObjRemoved, roi, 'TextLayout', 'Word','CharacterSet','A':'Z');
    c = cell(1,numel(results));
    for i = 1:numel(results)
        c{i} = deblank(results(i).Text);
    end
    
    % Find non-empty OCR bboxes
    cI = find(~cellfun(@isempty,c'));
    roi2 = roi(cI,:);

    % Black out the letters from the original binary image
    imgBW_COPY = imgBW;
    for i = 1:length(roi2)
        ROI = round(roi2(i,:));
        x1 = ceil(ROI(1));
        x2 = round(x1 + ROI(3));
        y1 = ceil(ROI(2));
        y2 = round(y1 + ROI(4));
        imgBW_COPY(y1:y2, x1:x2) = 0;
    end
    
    imgBW = imgBW_COPY;
    if PF==1, figure(6),imshow(imgBW);end

end
