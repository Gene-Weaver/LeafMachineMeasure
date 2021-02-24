% Enlarge bboxes by category
% Goal is to better fit rulers

% Setup to assume that WIDTH = long side of the ruler,
%                      HEIGHT = short side
% Then the dims will swap the orientation as needed
% When X or Y = 0, then bbox size size not change

function newBBoxes = LMM_enlargeBBoxesByCategory(bboxes,category,dim)
    [S1,~] = size(bboxes);
    newBBoxes = bboxes;

    if category == "barcode"
        scaleH = 2;
        scaleW = 2;
    end
    
    
    if category == "color"
        scaleH = 0.5;
        scaleW = 0.5;
    end
    
    
    if category == "text"
        scaleH = 0.25;
        scaleW = 0.25;
    end
    
    
    if category == "ruler"
        scaleH = 4;
        scaleW = 4; 
    end
    
    
    if category == "unitImp"
        scaleH = 2;
        scaleW = 2;  
    end
    
    
    if category == "unitMetric"
        scaleH = 2;
        scaleW = 2;  
    end 
    
    % Resize    
    for i = 1:S1
        box = bboxes(i,:);
        if box(3) > box(4) % This is the long side horrizontal 
            box = enlargeBBox(box, scaleW, scaleH, dim);
        else 
            box = enlargeBBox(box, scaleW, scaleH, dim);
        end
            
        
        
        newBBoxes(i,:) = box;
    end


end


function box = enlargeBBox(box, scaleW, scaleH,dim)
    dimX = dim(2);
    dimY = dim(1);
    box2 = box;
    if box(3) > box(4)
        X = (box(3) * scaleW); 
        box(1) = round(box(1) - (X/(scaleW*2)));
        box(3) = round(box(3) + (X/scaleW));%(2*X));
        
        Y = (box(4) * scaleH);
        box(2) = round(box(2) - (Y/(scaleH*2)));
        box(4) = round(box(4) + (Y/scaleH));%(2*Y));
        
        if box(1) < 0, box(1) = 1; end
        if box(2) < 0, box(2) = 1; end
        
        if box(1)+box(3) > dimX, box(3) = (box(3) - ((box(1)+box(3)) - dimX + 1)); end
        if box(2)+box(4) > dimY, box(4) = (box(4) - ((box(2)+box(4)) - dimY + 1)); end
        
    else
        X = (box(3) * scaleH); 
        box(1) = round(box(1) - (X/(scaleH*2)));
        box(3) = round(box(3) + (X/scaleH));%(2*X));
        
        Y = ((box(4) * scaleW));
        box(2) = round(box(2) - (Y/(scaleW*2)));
        box(4) = round(box(4) + (Y/scaleW));%(2*Y));
        
        if box(1) < 0, box(1) = 1; end
        if box(2) < 0, box(2) = 1; end
        
        if box(2)+box(4) > dimY, box(4) = (box(4) - ((box(2)+box(4)) - dimY + 1)); end
        if box(1)+box(3) > dimX, box(3) = (box(3) - ((box(1)+box(3)) - dimX + 1)); end
        
    end
end