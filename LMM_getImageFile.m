% Build filename structure
% Read image
% Get basic dimensions

function imgProps = LMM_getImageFile(file,setParameters)

    imgNameBase = char(file.name);
    filename = strsplit(string(imgNameBase),".");
    filename = char(filename{1});
    filenameRead = [setParameters.inDir,string(imgNameBase)];
    if isunix, filenameRead = strjoin(filenameRead,"/"); else, filenameRead = strjoin(filenameRead,"\"); end    
    img = imread(filenameRead);

    % Read image, get size
    [rows,cols,~] = size(img);
    %Dim = min(DimN,DimM);
    megapixels = rows*cols/1000000;
    
    if megapixels > setParameters.maxMegapixels
        if rows >= cols %Correct portrait orrientation
            longSide = round(sqrt( (rows/cols) * (setParameters.maxMegapixels * 1000000)));
            scaleFactor = round(longSide*(cols/rows));
            img = imresize(img, [longSide scaleFactor ]);
            [rows,cols,~] = size(img);
            megapixels = rows*cols/1000000;
        elseif rows < cols
            longSide = round(sqrt( (cols/rows) * (setParameters.maxMegapixels * 1000000)));
            scaleFactor = round(longSide*(rows/cols));
            img = imresize(img, [scaleFactor longSide]);
            [rows,cols,~] = size(img);
            megapixels = rows*cols/1000000;
        end  
    end
    
    imgProps.filename = filename;
    imgProps.filenameRead = filenameRead;
    imgProps.img = img;
    imgProps.rows = rows;
    imgProps.cols = cols;
    imgProps.megapixels = megapixels;
    
end