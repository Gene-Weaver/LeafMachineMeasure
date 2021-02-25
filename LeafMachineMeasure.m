% Wrapper for implementing measurement conversion, pixels to metric


function LeafMachineMeasure(setParameters)
    if isunix, SYM = "/"; else, SYM = "\"; end
    addpath(strcat(".",SYM,"YOLO"));
    
    % Handle directories
    dirList = LMM_buildDirOut(setParameters);
    
    % Evaluate YOLO Networks 
    % Load YOLOv2 network
    LMM_printToConsole("net",[],[],[],[]);
    net = load(strcat(".",SYM,"YOLO",SYM,"net_YOLO_gTruthV2_ShufL_MWK_VAL20_MobileNet5A_Fr61_500E200.mat"));
    net = net.net_YOLO_gTruthV2_ShufL_MWK_VAL20_MobileNet5A_Fr61_500E200;
    
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
    ind = 1;
    timeOverall_START = tic;
    for file = imgFiles'
        
        % Build filename
        imgProps = LMM_getImageFile(file,setParameters);
        LMM_printToConsole("file",ind,fLen,imgProps.filename,[]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%      Run YOLO object detection      %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        timeDetect_START = tic;
        
        detectionData = LMM_detectObjects(net,imgProps,setParameters,dirList);
        
        timeDetect_END = toc(timeDetect_START);
        LMM_printToConsole("detect",ind,fLen,[],timeDetect_END);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%   Metric Conversion From SubImages  %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        timeMeasure_START = tic;

        measurementData  = LMM_calcMetricDistance(detectionData,imgProps,setParameters,dirList);
        
        
        timeMeasure_END = toc(timeMeasure_START);
        LMM_printToConsole("measure",ind,fLen,[],timeMeasure_END);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%        ?      Save Data      ?        %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ind = ind + 1;
    end
    %writetable(DwC10RandImg_MP,"D:\Dropbox\ML_Project\Image_Database\LeafMachine_OverviewStats\DwC_10RandImg_MegapixelByFilename.xlsx")







    timeOverall_END = toc(timeOverall_START);
    LMM_printToConsole("overall",ind,fLen,[],timeOverall_END);
end