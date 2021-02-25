function dataTicks = LMM_findTickMarks(imgData,detectData,imgProps,setParameters,dirList)


    % TYPE = "mid" ;% gray or mid or blocks; background color, mid = b&w, gray = gray
    % COLOR = "black" ;% "white", "black", "NA"; tick color

    nObjects = length(imgData);
    dataTicks = {};
    for i = 1:nObjects
        indObject = string(i);
        % First pass, pick optimal TYPE and COLOR
        img = imgData{i};
        label = string(detectData.labels(i));
        
        [type, color] = pickRulerFormat(label);
        
        imgSet = LMM_correctRulerAnglePreprocess(img,type,color); %[img,imgGS,imgBW,imgBW_1pass,imgBW_2pass]
        
        dataOut = LMM_calculateDistance(imgSet,imgProps,setParameters,dirList,label,indObject);
        dataTicks{i} = dataOut;
    end
    
    
    %%%%%%%%% Pick best distance, save ruler overlay of WHOLE image
    G = 1;

end

function [type, color] = pickRulerFormat(label)
    
    if label == "blocks"
        type = "mid";
        color = "NA";
        
    elseif label == "blocksAndTicks"
        type = "mid";
        color = "black";
    
    elseif label == "text"
        type = "mid";
        color = "black";    
    
    elseif label == "ticksBlack"
        type = "mid";
        color = "black";
        
    elseif label == "ticksWhite"
        type = "mid";
        color = "white";
        
    elseif label == "ticksBlackBGgray"
        type = "gray";
        color = "black";
    
    elseif label == "tiffen"
        type = "gray";
        color = "black";
        
    elseif label == "kodak"
        type = "gray";
        color = "black";
    end
end