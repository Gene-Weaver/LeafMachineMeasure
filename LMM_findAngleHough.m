% Based on:
% Jan Motl (2020). Straighten image (https://www.mathworks.com/matlabcentral/fileexchange/40239-straighten-image), MATLAB Central File Exchange. Retrieved April 19, 2020.

function angle = LMM_findAngleHough(img)
    p = 0.1;
    
    % Edge
    E = edge(img,'prewitt');
    
    % Hough trans
    [H, T, ~] = hough(E,'Theta',-90:p:90-p);  
    
    % Find most dominant direction
    % Angle variance
    data = var(H); 
    
    % Given right angles
    fold = floor(90/p);         
    data = data(1:fold) + data(end - fold + 1:end);
    
    % Prominent peaks
    [~,column] = max(data);
    
    % Get angle
    angle = -T(column);
    angle = mod(45+angle,90)-45;
end