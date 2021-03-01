% This hold the actual location and calculations for converting pixrls distances
% to metric distances


function dataOut = LMM_calculateDistance(imgSet,imgProps,setParameters,dirList,label,indObject)
    % Unpack
    img = imgSet.img;
    imgBW = imgSet.imgBW;
    type = imgSet.type;
    color = imgSet.color;
    filename = imgProps.filename;
    
    %%%%%%%BELOW IS TEMP FOR TESTING IT
    %ticksData = LMM_fitTicksStandard(imgBW,imgProps,dirList,setParameters,type,color);

    if ((label == "blocks") || (label == "blocksAndTicks"))
        dataOut = LMM_fitTicksBlocks(imgBW);
        if setParameters.printRulerOverlay
            if ~isempty(dataOut.plotPts)
                dataOut = LMM_save1cmOverlay_Blocks(imgSet,imgProps,dirList,dataOut,indObject);
            end
        end

        % Save data
        
        
    elseif ((label == "ticksBlack") || (label == "ticksWhite") || (label == "text"))
       dataOut = LMM_fitTicksStandard(imgBW,imgProps,dirList,setParameters,imgSet,type,color,indObject);
        
    elseif ((label == "ticksBlackBGgray") || (label == "tiffen") || (label == "kodak"))
        %dataOut = LMM_fitTicksGray(imgBW,imgProps,dirList,type,color,indObject);
        dataOut = [];
    end
        
        

      

        

%     distSummaryt = cell(1,length(distHeaders2));
%     distSummaryt = cell2table(distSummaryt);
%     distSummaryt.Properties.VariableNames = distHeaders2;
%     distSummaryt.name = NAME;
%     distSummaryt.pass = string(min_Wvar_Ypos);
%     distSummaryt.calculated_dist = CONVERSION_FACTOR;
%     distSummaryt.method = CONVERSION_METHOD;
%     %distSummary = [distSummary; distSummaryt];
%     %LOWEST = [LOWEST; PASS];
%     
%     dataOut.distSummaryt = distSummaryt;
%     dataOut.distScanlines = distScanlines;
%     dataOut.imgPrint = imgPrint;
        
end