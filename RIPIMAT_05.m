function processed = RIPIMAT_05(image, ripimatmode)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% Radiography Image Processing for IMAT (RIP-IMAT)

% This tool provides processing capabilities for neutron radiographies
% aquired with the MCP detector on IMAT. Images are assumed to be in the
% 512x512 format.

% Processes for use with the BENRA code include:
% - Remove Black and White Outliers
% - Divide flat field
% - Substract dark field (if available)
% - 

% Improve cropfactor

if ripimatmode == 0
    processed = image;
    
elseif ripimatmode == 1
    % Crop image to remove border aberrations
    processed = image;
    s = size(processed);
    processed = imcrop(processed, [6 6 s(1,1)-12 s(1,2)-12]);
    processed = filloutliers(processed, 'linear', 'percentiles', [1 100]);
    processed = filloutliers(processed, 'pchip', 'movmedian', 3);       

elseif ripimatmode == 2
    % Takes ino input absolute range, returns summed and corrected images
    processed = image;
    processed = filloutliers(processed, 'pchip', 'movmedian', 9);
    processed = medfilt2(processed);
%    processed = imgaussfilt(processed);
    processed = uint8(processed);
    K = processed(processed>30);
    S = stretchlim(K);
    J = imadjust(processed,S,[]);
    processed = J;   

elseif ripimatmode == 3
    % Takes ino input absolute range, returns summed and corrected images
    processed = image;
    processed = filloutliers(processed, 'linear', 'percentiles', [0 95]);
    processed = imgaussfilt(processed);
    processed = medfilt2(processed); 

    
elseif ripimatmode == 4
    % Crop image to remove border aberrations
    processed = image;
    s = size(processed);
    processed = imcrop(processed, [6 6 s(1,1)-12 s(1,2)-12]);
    
elseif ripimatmode == 5
    % Takes ino input absolute range, returns summed and corrected images
    processed = image;
    processed = filloutliers(processed, 'pchip', 'movmedian', 3);
    processed = medfilt2(processed);
%    processed = imgaussfilt(processed);
    processed = im2uint8(processed);
%      
    

end
% outputArg1 = inputArg1;
% outputArg2 = inputArg2;
end



%% Bin
% tempSummedIP = filloutliers(tempSummedI, 'pchip', 'movmedian', 70, 'ThresholdFactor', 6);
% processed = imadjust(processed);
% processed = uint8(processed); 'movmedian', 6
%tempSummedIP = fillmissing(tempSummedIP, 'pchip');
%tempSummedIP = imgaussfilt(tempSummedI, 2);
% 
% %    processed = imadjust(processed);
