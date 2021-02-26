%%%     Get binary masks from 'C' variable from segmentation
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function binaryMasks = LMM_getBinaryMasks(C)
    % Retrieve binary masks
    stem = C == 'stem';
    leaf = C == 'leaf';
    text = C == 'text';
    fruitFlower = C == 'fruitFlower';
    background = C == 'background';
    
    binaryMasks.leaf = leaf;
    binaryMasks.stem = stem;
    binaryMasks.fruitFlower = fruitFlower;
    binaryMasks.background = background;
    binaryMasks.text = text;    
    
end