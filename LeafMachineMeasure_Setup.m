%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     Contact: LeafMachine@colorado.edu
%%%
%%%     University of Michigan, Ann Arbor
%%%     Department of Ecology and Evolutionary Biology

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit the parameters in this file 
% to setup the LeafMachineMeasure tool.
% 
% Only modify input on right-hand side of " = "
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LeafMachineMeasure_Setup()
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Edit the parameters below for %
    %  command line implementation  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % Directory
    setParameters.inDir = "D:\Dropbox\ML_Project\LM_YOLO_Training\YOLO_Test_Imgs";
    %setParameters.inDir = "A:\Image_Database\DwC_10RandImg";
    setParameters.outDir = "D:\D_Desktop\TEST_YOLO_5AshufAug_NoEnlarge";
    
    
    % Save summary images containing bounding boxes
    setParameters.printSummary = true; % Use EXACTLY one of the following, not in quotes: true || false
    
    
    % Save each individual bounding box as an image 
    % *NOTE* This will reault in numerous small images per input image, 
    %        not recommended for large batches
    setParameters.printCropped = true; % Use EXACTLY one of the following, not in quotes: true || false
    
    
    setParameters.printRulerOverlay = true;
    setParameters.printScanlineMetadata = true;
    setParameters.useSemSeg = false;
    setParameters.useSemSeg_gpu = "gpu"; % Use EXACTLY one of the following: "auto" || "gpu" || "cpu"
    
    setParameters.maxMegapixels = 24; % Integer value. Higher than 20 requires powerful GPU
    
    
    % Enlarge bounding boxes around found objects
    % *NOTE* Enable this option if you notice that bounding boxes
    %        do not quite align with the image, this may improve performance
    setParameters.enlarge = false; % Use EXACTLY one of the following, not in quotes: true || false
    
    
    % Set detection strength
    % *NOTE* Strict return the least number of boxes and may not work
    %        well for all datasets. Avg
    setParameters.detectStrength = "Avg"; % Use EXACTLY one of the following: "Strict" || "Broad" || "Avg"
    
    
    setParameters.measureText = false;
    
    
    setParameters.startIndex = 48; % To resume partway through a run

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    Do NOT edit below code     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Call LeafMachineMeasure()
    LeafMachineMeasure(setParameters)
end

% Temp variables for me *** DELETE LATER ***

    % Directory = "D:\Dropbox\ML_Project\LM_YOLO_Training\YOLO_Test_Imgs";
    % outDir = "D:\Dropbox\ML_Project\LM_YOLO_Training\YOLO_Test_Out-Avg";


    %Directory = "/home/brlab/Dropbox/ML_Project/LM_YOLO_Training/YOLO_Test_Imgs";
    %outDir = "/home/brlab/Dropbox/ML_Project/LM_YOLO_Training/YOLO_Test_Out-Strict-network_YOLO_MobileNet32A96A_gTruth_YOLO_Fr114_3890E0_01";

    %Directory = "D:\Dropbox\treeVRE\Image_Sets_BurOak\Bur_Oak_Images";
    %outDir = "D:\D_Desktop\YOLO_Test_BurOak-Avg-net_YOLO_gTruthV2_MWK_VAL20TS_MobileNet32A_Fr0_1000E450";

