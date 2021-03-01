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
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%      Set Directories      %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inDir should not contain subdirectories 
    % outDir will be created if it does not already exist 
    
    %setParameters.inDir = "D:\Dropbox\treeVRE\Image_Sets_BurOak\Bur_Oak_Images";
    setParameters.inDir = "D:\Dropbox\ML_Project\LM_YOLO_Training\YOLO_Test_Imgs";
    %setParameters.inDir = "A:\Image_Database\DwC_10RandImg";
    setParameters.outDir = "D:\D_Desktop\TEST_YOLO_BurOak_5AshufAug_NoEnlarge";
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%       Save Options        %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use EXACTLY one of the following, not in quotes: true || false
    
    % Save summary images containing bounding boxes
    setParameters.printSummary = true; % DEFAULT: true
     
    
    % Save each individual bounding box as an rgb image 
    % *NOTE* This will reault in numerous small images per input image, not recommended for large batches
    setParameters.printCropped = true; % DEFAULT: false
    
    
    % Save all attempted and successful ruler prediction images
    setParameters.printRulerOverlay = true; % DEFAULT: true
    
    
    % Save a csv file for each input image, contains all intermediate tickmark selection metadata
    setParameters.printScanlineMetadata = true; % DEFAULT: false
    
    
    % Save a csv file for each input image, contains only the highest confidence measurements 
    %setParameters.printIndividualData = true; % DEFAULT: false
    
    
    % Save copy of output data at regular intervals 
    % If number is set greater than number of input files, then it will save one temp data file halfway throguh
    %setParameters.printDataFreq = 50; % DEFAULT: 50 
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%    Segmentation Options   %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % There are two options for locating text in an image
    %     1. Using LeafMachine's semantic segmentation algorithm
    %            |----> setParameters.useSemSeg = true
    %     OR
    %     2. Using non-machine learning computer vision
    %            |----> setParameters.useSemSeg = false
    % Try both on your data and see which gives better results, they perform differently
    setParameters.useSemSeg = false; % DEFAULT: false
    
    
    % If your computer/cluster has a gpu, set to "gpu", otherwise set to "auto" in most cases
    % Using a cpu for segmentation and detection is ~7x slower than using a gpu
    %            |----> setParameters.useSemSeg_gpu = "gpu"
    % This setting applies to *BOTH* the semantic segmenation option, and the ruler object detection algorithms
    setParameters.useSemSeg_gpu = "gpu"; % Use EXACTLY one of the following: "auto" || "gpu" || "cpu"
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%    Image Size / Resize    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % A gpu with 8GB of VRAM (common consumer-grade) can stably handle images up to 20 megapixels
    % A gpu with 24GB of VRAM (Nvidia Quadro GPUs) can typically handle images up to 60 megapixels
    %            |----> setParameters.maxMegapixels = 24; 
    %
    % If you receive this error message:
    %            |----> " Out of memory on device. To view more detail about available memory on the GPU, use 'gpuDevice()' "
    % Try lowering image megapixel size, image will be resized to be no larger than the set vaule
    setParameters.maxMegapixels = 24; % DEFAULT: 50, must be an integer, not in quotes
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%   Enlarge Bounding Boxes  %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Enlarge bounding boxes around found objects. If the bounding boxes are cutting of rulers, set to true 
    % and the bouding boxes for rulers and barcodes will be enlarged
    setParameters.enlarge = false; % DEFAULT: false
    
    
    % Set detection strength. This is the minimum ruler detection confidence. 
    % *NOTE* Strict return the least number of boxes and may not work well for all datasets
    % Most boxes returned --- "Broad"  >  "Avg"  >  "Strict" --- Least boxes returned
    % Use EXACTLY one of the following: "Strict" || "Avg" || "Broad"
    setParameters.detectStrength = "Avg"; % DEFAULT: "Avg"
    
    
    % Sometimes rulers are predicted to be text. 
    % Set to true to try to locate tick marks in text boxes.
    setParameters.measureText = false; % DEFAULT: false
    
    
    % Set this value to an integer to restart processing partway through a batch. 
    setParameters.startIndex = 1; % DEFAULT: 1

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    Do NOT edit below code     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Call LeafMachineMeasure()
    LeafMachineMeasure(setParameters)
    warning('off', 'images:bwfilt:tie')
end