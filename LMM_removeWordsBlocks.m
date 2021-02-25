% Nested function inside correctRulerAngle_Preprocess()
% Removes text from the gray image so it doesn't mess with the tick mark
% function 

function imgBW = LMM_removeWordsBlocks(imgBW,PF)
    % Remove largest 3 ogjects, should let the rest of the code ignore the
    % tick marks
    % imshow(imgBW)
    numWhitePixels = sum(imgBW(:));
    numBlackPixels = sum(~imgBW(:));
    if numWhitePixels>= numBlackPixels, imgBW = imcomplement(imgBW);end
    imgBW = bwareaopen(imgBW,19);
    
    largestObjRemoved = imbinarize(imgBW.*(~bwareafilt(imgBW,3)));
    if PF==1, figure(5),imshow(largestObjRemoved);end
    
    imgBW2 = imgBW;
    imgBW2(largestObjRemoved) = 0;
    
    imgBW = imcomplement(imgBW2);  %%%%% Main squares are white, will find center of squares
    %imgBW = imgBW2;                 %%%%% Main squares are black, will lines between squares

    if PF==1, figure(6),imshow(imgBW);end

end
