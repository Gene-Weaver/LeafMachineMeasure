function dirList = LMM_buildDirOut(setParameters)
    outDir = setParameters.outDir;
    
    
    % Make the outDir if ~exist
    if ~exist(fullfile(outDir), 'dir');mkdir(fullfile(outDir));end
    
    if ~exist(fullfile(outDir,'Data'), 'dir');mkdir(fullfile(outDir,'Data'));end
    formatSpec = 'Created directory for data \n';
    fprintf(formatSpec);
    
    
    % Make the Summary outDir if ~exist
    if setParameters.printSummary == true
        if ~exist(fullfile(outDir,'Summary'), 'dir');mkdir(fullfile(outDir,'Summary'));end
        dirList.summary = fullfile(outDir,'Summary');
        formatSpec = '----- Created directory for summary images \n';
        fprintf(formatSpec);
    else
        dirList.summary = [];
        formatSpec = '***** User skipped saving summary images \n';
        fprintf(formatSpec);
    end
    
    
    % Make the RulerOverlay outDir if ~exist
    if setParameters.printRulerOverlay == true
        if ~exist(fullfile(outDir,'RulerOverlay'), 'dir');mkdir(fullfile(outDir,'RulerOverlay'));end
        dirList.rulerOverlay = fullfile(outDir,'RulerOverlay');
        formatSpec = '----- Created directory for ruler overlay images \n';
        fprintf(formatSpec);
    else
        dirList.rulerOverlay = [];
        formatSpec = '***** User skipped saving ruler overlay images \n';
        fprintf(formatSpec);
    end
    
    
    % Make the ScanlineMetadata outDir if ~exist
    if setParameters.printScanlineMetadata == true
        if ~exist(fullfile(outDir,'ScanlineMetadata'), 'dir');mkdir(fullfile(outDir,'ScanlineMetadata'));end
        dirList.scanline = fullfile(outDir,'ScanlineMetadata');
        formatSpec = '----- Created directory for scanline metadata \n';
        fprintf(formatSpec);
    else
        dirList.scanline = [];
        formatSpec = '***** User skipped saving scanline metadata \n';
        fprintf(formatSpec);
    end
    

    
    % Make the Bounding Box Cropped Images outDir if ~exist
    if setParameters.printCropped == true
        if ~exist(fullfile(outDir,'Cropped'), 'dir');mkdir(fullfile(outDir,'Cropped'));end
        if ~exist(fullfile(fullfile(outDir,'Cropped'),'Barcode'), 'dir');mkdir(fullfile(fullfile(outDir,'Cropped'),'Barcode'));end
        if ~exist(fullfile(fullfile(outDir,'Cropped'),'Text'), 'dir');mkdir(fullfile(fullfile(outDir,'Cropped'),'Text'));end
        if ~exist(fullfile(fullfile(outDir,'Cropped'),'Ruler'), 'dir');mkdir(fullfile(fullfile(outDir,'Cropped'),'Ruler'));end
        if ~exist(fullfile(fullfile(outDir,'Cropped'),'Color'), 'dir');mkdir(fullfile(fullfile(outDir,'Cropped'),'Color'));end
        if ~exist(fullfile(fullfile(outDir,'Cropped'),'Metric'), 'dir');mkdir(fullfile(fullfile(outDir,'Cropped'),'Metric'));end
        if ~exist(fullfile(fullfile(outDir,'Cropped'),'Imperial'), 'dir');mkdir(fullfile(fullfile(outDir,'Cropped'),'Imperial'));end

        dirList.barcode = fullfile(fullfile(outDir,'Cropped'),'Barcode');
        dirList.text = fullfile(fullfile(outDir,'Cropped'),'Text');
        dirList.ruler = fullfile(fullfile(outDir,'Cropped'),'Ruler');
        dirList.color = fullfile(fullfile(outDir,'Cropped'),'Color');
        dirList.unitsMetric = fullfile(fullfile(outDir,'Cropped'),'Metric');
        dirList.unitsImp = fullfile(fullfile(outDir,'Cropped'),'Imperial');
        
        formatSpec = '----- Created directories for bounding box cropped images \n';
        fprintf(formatSpec);
    else
        dirList.barcode = [];
        dirList.text = [];
        dirList.ruler = [];
        dirList.color = [];
        dirList.unitsMetric = [];
        dirList.unitsImp = [];
        formatSpec = '***** User skipped saving bounding box cropped images \n';
        fprintf(formatSpec);
    end
end
