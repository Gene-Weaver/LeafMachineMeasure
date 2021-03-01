function cleanedTable = LMM_cleanupImageData(imgProps, dirList, setParameters, dataTicks_Ruler,dataTicks_Text)
    propsHeaders = {'Selected' 'ConversionMessage' 'Group' 'name' 'scan' 'method' 'yPosition' 'w_var' 'variance' 'n_peaks' 'dist_mean' 'dist_har' 'dist_geo'};
    infoImageHeaders = {'ImageName' 'nObjectsMeasured' 'PixelsPerMM' 'PixelsPerMM_ManuallyValidated' 'ImageFileLocation'};
    
    infoObjectHeaders = {'ObjectName' 'PixelsPerUnit_1' 'Unit_1' 'PixelsPerUnit_2' 'Unit_2' 'PixelsPerUnit_3' 'Unit_3' 'ValidationMessage' 'ValidationScore' 'ObjectFileLocation'};
    
    nRulerBoxes = length(dataTicks_Ruler);
    if ~isempty(dataTicks_Text)
        nTextBoxes = length(dataTicks_Ruler);
    else
        nTextBoxes = 0;
    end
    
    
    allUsedTables = [];
    allUsedBlocks = [];
    % Extract data from ruler boxes
    for i = 1:nRulerBoxes
        rulerData = dataTicks_Ruler{i};
        if rulerData.method == "standard" % Used the tick mark approach, not the blocks approach
            rulerData_usedTable = rulerData.usedTable;
            %rulerData.
            
            
            allUsedTables = [allUsedTables; rulerData_usedTable];
            
            rulerData_usedTable = [];
        else % Used the blocks approach, not the tick mark approach
            blocksData = cell(1,length(propsHeaders));
            blocksData = cell2table(blocksData);
            blocksData.Properties.VariableNames = propsHeaders;
            
            blocksData.Selected{1} = "Used";
            blocksData.ConversionMessage{1} = "Blocks";
            blocksData.Group{1} = "Primary";
            
            fullName = rulerData.fnameRulerOverlay;
            fname = strsplit(fullName,[setParameters.SYM,"."]);
            fname = fname(length(fname)-1);
            blocksData.name{1} = fname;
            
            blocksData.scan{1} = rulerData.scan;
            blocksData.method{1} = rulerData.method;
            blocksData.yPosition{1} = rulerData.yPosition;
            blocksData.w_var{1} = rulerData.wVar;
            blocksData.variance{1} = rulerData.variance;
            blocksData.n_peaks{1} = rulerData.nPeaks;
            blocksData.dist_geo{1} = rulerData.convFactorMM;
            % Don't have these data for blocks
            blocksData.dist_mean{1} = [];
            blocksData.dist_har{1} = [];
            
                  
            
            
            
            
            
            allUsedBlocks = [allUsedBlocks; blocksData];
        end
        
        
    end
    
    

    cleanedTable = [];
end