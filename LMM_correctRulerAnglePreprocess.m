
% Funtion to correct off 180 (hor.) rulers prior to processing
% also creates the binary, grayscale images

%%% color == ( "white" || "black" || "NA")
%%% type == ( "gray" || "mid" )
%               - "gray" is for tiffen, Kodak rulers, pairs with "NA"
%               - "mid" is for everything else, pairs with "white" or "black"

function imgSet = LMM_correctRulerAnglePreprocess(img,type,color,setParameters)
    pixelFill = 9;
    PF = 0;
    if PF==1, figure(1),imshow(img);end
    
    % Make image hor.
    imgGS = rgb2gray(img);
    [H, W, ~] = size(imgGS);
    if H > W
        img = imrotate(img,90);
        imgGS = imrotate(imgGS,90);
    end
    
    
    %if ~setParameters.useSemSeg
        if type == "gray"
            try
                imgBW = imbinarize(imgGS,'adaptive','ForegroundPolarity','bright','Sensitivity',0.7);
                imgBW = LMM_removeWords(imgBW,PF);

                imgBW = imfill(imgBW,'holes');
                imgBW = bwareaopen(imgBW,pixelFill);
                imgBW_1pass = imgBW;
                imgBW_2pass = imgBW;
            catch
                %thresh = multithresh(imgGS,9);
                thresh = multithresh(imgGS,2);
                seg_I = imquantize(imgGS,thresh);
                seg_II = seg_I;
                %RGB = label2rgb(seg_II); 
                %imshow(RGB)
                % Combine lighter colors with black  
                seg_I(seg_II == 3) = 1;
                % Convert to binary
                seg_I(seg_II == 2) = 0;
                imgBW = imbinarize(seg_I);
                %imshow(imgBW)

                % Fill in small holes, imcomplement, fill holes, imcomplement back
                imgBW = imfill(imgBW,'holes');
                imgBW = bwareaopen(imgBW,pixelFill);

                %imshow(imgBW)
                % Remove Text
                imgBW = LMM_removeWords(imgBW,PF);
                imgBW_1pass = imgBW;
                imgBW_2pass = imgBW;
                %imshow(imgBW)
            end 
        elseif type == "mid"
            if color == "black"
                imgBW = imbinarize(imgGS,'adaptive','ForegroundPolarity','dark','Sensitivity',0.5);
                imgBW = bwareaopen(imgBW,19);
                imgBW_1pass = imcomplement(imfill(imcomplement(imgBW),'holes'));
                imgBW_2pass = imcomplement(imfill(imgBW_1pass,'holes'));
                if PF==1, figure(4),imshow(imgBW_1pass);end

            elseif color == "white"
                imgBW = imbinarize(imgGS,'adaptive','ForegroundPolarity','dark','Sensitivity',0.5);
                imgBW = imcomplement(imgBW);
                imgBW = bwareaopen(imgBW,19);
                imgBW_1pass = imcomplement(imfill(imcomplement(imgBW),'holes'));
                imgBW_2pass = imcomplement(imfill(imgBW_1pass,'holes'));
                if PF==1, figure(4),imshow(imgBW_1pass);end

            elseif color == "NA"
                imgBW = imbinarize(imgGS);
                imgBW = imcomplement(imgBW);
                if PF==1, figure(4),imshow(imgBW);end
                imgBW_1pass = imgBW;
                imgBW_2pass = imgBW;
                if PF==1, figure(4),imshow(imgBW);end

                imgBW = LMM_removeWordsBlocks(imgBW,PF);
            end
        end 
    
    
        % Fill holes
        if color == "NA"
        else
            % invert if white is majority of pixels
            numWhitePixels = sum(imgBW(:));
            numBlackPixels = sum(~imgBW(:));
            if numWhitePixels>= numBlackPixels, imgBW = imcomplement(imgBW);end
            imgBW = imfill(imgBW,'holes');
%             imgBW2 = imcomplement(imfill(imcomplement(imgBW),'holes'));

%             imgBW3 = imgBW;
%             imgBW3(imgBW2) = 0;
% 
%             imgBW4 = bwareaopen(imgBW3,9);


    %         [L,n] = bwlabel(imgBW);
    %         h = regionprops(imgBW,'Area','Eulernumber');
    %         figure(12)
    %         imshow(imgBW3)
    %         imshow(imgBW4)
    %         imshow(imgBW)
        end
     
%     else
%         imgGS = rgb2gray(img);
%         imgBW = imgGS;
%         imgBW_1pass = imgGS;
%         imgBW_2pass = imgGS;
        
%         imgSet.img = img;
%         imgSet.imgGS = imgGS;
%         imgSet.imgBW = imgBW;
%         imgSet.imgBW_1pass = imgBW_1pass;
%         imgSet.imgBW_2pass = imgBW_2pass;
    
%end %%% USING SEMANTIC SEGMENTATION INSTEAD OF THE RGB IMAGE, we skip the binarization and go straight to angle correction 
    

    % Calc image roatation 
    angle1 = -LMM_findAngleHough(imgGS);
    try
        angle2 = -LMM_findAngleHough(imgBW_1pass);
    catch
        angle2 = -LMM_findAngleHough(imgBW);
    end
    %angle3 = -horizonHough(imgBW_2pass);
    %aSet = [angle1;angle2;angle3];
    aSet = [angle1;angle2];
    aSet2 = [NaN;NaN;NaN];

    % Check to see if any of them show alignment
    %if ( ((angle1 == 90) || (angle1 == 0)) || ((angle2 == 90) || (angle2 == 0)) ||  ((angle3 == 90) || (angle3 == 0)) )
    if (((angle1 == 90) || (angle1 == 0)) || ((angle2 == 90) || (angle2 == 0))) 
        angle_Corrected = 0;
    elseif ((angle1 < 0) && (angle2 < 0 ))% otherwise take the min
        angle_Corrected = max(aSet(aSet~=0));
    elseif ((angle1 > 0) && (angle2 > 0 ))
        angle_Corrected = min(aSet(aSet~=0));
    else
        angle_Corrected = 0;
    end
    
    
    % Rotate
    if angle_Corrected == 0
    else
        img = imrotate(img,angle_Corrected);
        if PF==1, figure(2),imshow(img);end

        imgGS = imrotate(imgGS,angle_Corrected);
        imgBW = imrotate(imgBW,angle_Corrected);
        try
        imgBW_1pass = imrotate(imgBW_1pass,angle_Corrected);
        imgBW_2pass = imrotate(imgBW_2pass,angle_Corrected);
        catch
        end
    end
    
    if PF==1, figure(3),imshow(img);end

    figure(8);
    imshow(imgBW);
    try
    %figure(9);
    %imshow(imgBW4);
    catch
    end
    
    imgSet.img = img;
    imgSet.imgGS = imgGS;
    imgSet.imgBW = imgBW;
    imgSet.imgBW_1pass = imgBW_1pass;
    imgSet.imgBW_2pass = imgBW_2pass;
    imgSet.type = type;
    imgSet.color = color;
end