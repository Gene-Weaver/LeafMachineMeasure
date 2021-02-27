% Wrapper for implementing measurement conversion, pixels to metric


function LeafMachineMeasure(setParameters)
    if isunix, SYM = "/"; else, SYM = "\"; end
    addpath(strcat(".",SYM,"YOLO"));
    addpath(strcat(".",SYM,"SemSeg"));
    
    % Handle directories
    dirList = LMM_buildDirOut(setParameters);
    
    % Load SemSeg Network
    LMM_printToConsole("netSeg",[],[],[],[]);
    net.SemSeg = load(strcat(".",SYM,"SemSeg",SYM,"network_deeplab_v2_Lexi_dynamicCrop_AWK_SEQ20.mat")); 
    net.SemSeg = net.SemSeg.deeplab_v2_Lexi_dynamicCrop_AWK_SEQ20;
    
    % Evaluate YOLO Networks 
    % Load YOLOv2 network
    LMM_printToConsole("net",[],[],[],[]);
    %net.YOLO = load(strcat(".",SYM,"YOLO",SYM,"net_YOLO_gTruthV2_ShufL_MWK_VAL20_MobileNet5A_Fr61_500E200.mat"));
    %net.YOLO = net.YOLO.net_YOLO_gTruthV2_ShufL_MWK_VAL20_MobileNet5A_Fr61_500E200;
    
    net.YOLO = load(strcat(".",SYM,"YOLO",SYM,"net_YOLO_gTruthV2_ShufLAug_MWK_VAL20_MobileNet5A_Fr61_500E200.mat"));
    net.YOLO = net.YOLO.net_YOLO_gTruthV2_ShufLAug_MWK_VAL20_MobileNet5A_Fr61_500E200;
    
    
    
%     net1 = load('D:\Dropbox\ML_Project\LM_YOLO_Training\Good_Models\net_YOLO_gTruthV2_ShufL_MWK_VAL20_MobileNet23A_Fr61_500E200.mat');
%     net1 = net1.net_YOLO_gTruthV2_ShufL_MWK_VAL20_MobileNet23A_Fr61_500E200;
% 
%     net2 = load('D:\Dropbox\ML_Project\LM_YOLO_Training\Good_Models\net_YOLO_gTruthV2_MWK_VAL20TS_MobileNet32A_Fr0_1000E450.mat');
%     net2 = net2.net_YOLO_gTruthV2_MWK_VAL20TS_MobileNet32A_Fr0_1000E450;
% 
%     net3 = load('D:\Dropbox\ML_Project\LM_YOLO_Training\Good_Models\net_YOLO_gTruthV2_ShufL_MWK_VAL20_MobileNet5A_Fr61_500E200.mat');
%     net3 = net3.net_YOLO_gTruthV2_ShufL_MWK_VAL20_MobileNet5A_Fr61_500E200 ;

%     net = net3;

    
    % Find images in inDir, count them
    imgFiles = dir(char(setParameters.inDir));
    imgFiles = imgFiles(~ismember({imgFiles.name},{'.','..'}));
    fLen = length(imgFiles);

    % Loop through image dir
    startIndex = setParameters.startIndex;
    
    timeOverall_START = tic;
    for indFile = startIndex:length(imgFiles)
        file = imgFiles(indFile);
        
        % Build filename
        imgProps = LMM_getImageFile(file,setParameters);
        LMM_printToConsole("file",indFile,fLen,imgProps.filename,[]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%  Run Semantic Segmentation for Text %%%%% % Note, in the full version of LeafMachine, this will have already taken place
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if setParameters.useSemSeg
            timeSeg_START = tic;
            imgText = LMM_basicSegmentation(net.SemSeg,imgProps.img,setParameters.useSemSeg_gpu);
            timeSeg_END = toc(timeSeg_START);
            LMM_printToConsole("seg",indFile,fLen,[],timeSeg_END);
        else
            imgText = [];
        end
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%      Run YOLO object detection      %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        timeDetect_START = tic;

        detectionData = LMM_detectObjects(net.YOLO,imgProps,imgText,setParameters,dirList);
        
        timeDetect_END = toc(timeDetect_START);
        LMM_printToConsole("detect",indFile,fLen,[],timeDetect_END);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%   Metric Conversion From SubImages  %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        timeMeasure_START = tic;

        measurementData  = LMM_calcMetricDistance(detectionData,imgProps,setParameters,dirList);
        
        
        timeMeasure_END = toc(timeMeasure_START);
        LMM_printToConsole("measure",indFile,fLen,[],timeMeasure_END);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%        ?      Save Data      ?        %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        indFile = indFile + 1;
    end
    %writetable(DwC10RandImg_MP,"D:\Dropbox\ML_Project\Image_Database\LeafMachine_OverviewStats\DwC_10RandImg_MegapixelByFilename.xlsx")







    timeOverall_END = toc(timeOverall_START);
    LMM_printToConsole("overall",indFile,fLen,[],timeOverall_END);
end