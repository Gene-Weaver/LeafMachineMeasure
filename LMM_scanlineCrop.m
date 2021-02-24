% Scanline crop

function [imgs,hpts] = LMM_scanlineCrop(img,boxPoints,h)

    [dimRows,dimCols,~] = size(img);
    
    % Get dims
    nBlocksRows = ceil(dimRows/(h/2));
    nBlocksCols = ceil(dimCols/(h/2));
    maxDimRows = (h/2)*nBlocksRows;
    maxDimCols = (h/2)*nBlocksCols;

    boundsRows_Floor = (maxDimRows - (h/2));
    boundsCols_Floor = (maxDimCols - (h/2));
    boundsRows_ShiftUp = dimRows - boundsRows_Floor;
    boundsCols_ShiftUp = dimCols - boundsCols_Floor;
    boundsRows_ShiftDn = h - boundsRows_ShiftUp;
    boundsCols_ShiftDn = h - boundsCols_ShiftUp;

    boundsRows_MaxDn = boundsRows_Floor - boundsRows_ShiftDn;
    boundsCols_MaxDn = boundsCols_Floor - boundsCols_ShiftDn;

    headers = {'Filenames'};
    data = cell(1,1);
    imgCropNames = cell2table(data);
    imgCropNames.Properties.VariableNames = headers;
    
    imgs = cell(nBlocksRows-1,1);
    hpts = cell(nBlocksRows-1,1);
    idx = 1;
    
    % Row
    for row = 2:nBlocksRows
        % Bottom right corner, very last crop - NOT USED FOR THIS FUNCTION
        if ((1 + ((h/2)-1)) >= boundsCols_Floor) && ((1+((h/2)*(row-2)) + ((h/2)-1)) >= boundsRows_Floor)
            imgCrop = imcrop(img,[boundsCols_MaxDn boundsRows_MaxDn  dimCols (h-1)]);
            pts = bbox2points([boundsCols_MaxDn boundsRows_MaxDn  dimCols (h-1)]);
            ptCrop = inpolygon(boxPoints.Location(:,1),boxPoints.Location(:,2),pts(:,1),pts(:,2));
            hpts{idx} = ptCrop;
            imgs{idx} = imgCrop;
            %figure(idx);imshow(imgCrop)
            idx = idx + 1;
        else
            if (1+((h/2)*(row-2)) + ((h/2)-1)) > boundsRows_Floor % The last top to bottom crop
                imgCrop = imcrop(img,[1 boundsRows_MaxDn dimCols (h-1)]);
                pts = bbox2points([1 boundsRows_MaxDn dimCols (h-1)]);
                ptCrop = inpolygon(boxPoints.Location(:,1),boxPoints.Location(:,2),pts(:,1),pts(:,2));
                hpts{idx} = ptCrop;
                imgs{idx} = imgCrop;
                idx = idx + 1;
            elseif (1 + ((h/2)-1)) > boundsCols_Floor % The last laft to right crop - NOT USED FOR THIS FUNCTION
                imgCrop = imcrop(img,[boundsCols_MaxDn (1+((h/2)*(row-2))) dimCols (h-1)]);
                pts = bbox2points([boundsCols_MaxDn (1+((h/2)*(row-2))) dimCols (h-1)]);
                ptCrop = inpolygon(boxPoints.Location(:,1),boxPoints.Location(:,2),pts(:,1),pts(:,2));
                hpts{idx} = ptCrop;
                imgs{idx} = imgCrop;
                idx = idx + 1;
            else % The typical crop
                imgCrop = imcrop(img,[1 (1+((h/2)*(row-2))) dimCols (h-1)]);
                pts = bbox2points([1 (1+((h/2)*(row-2))) dimCols (h-1)]);
                ptCrop = inpolygon(boxPoints.Location(:,1),boxPoints.Location(:,2),pts(:,1),pts(:,2));
                hpts{idx} = ptCrop;
                imgs{idx} = imgCrop;
                idx = idx + 1;
            end
        end
    end
end