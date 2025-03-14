function [full, compared] = RIAD_02(rad,flat,ref, D)
% Radiography Image Analysis and Differentiation (RIAD)
%   This function processes images for differenciation

meanIntensityValue = mean2(flat);
tempRadM = imlincomb(meanIntensityValue, rad);
tempRefM = imlincomb(meanIntensityValue, ref);

tempRadDiv = imdivide(tempRadM, flat);

tempRefDiv = imdivide(tempRefM, flat);

tempRadWarp = imwarp(tempRadDiv, D);

K = mean2(tempRadWarp);

full = tempRadWarp;

diff = minus(tempRadWarp, tempRefDiv);

compared = diff+K;

end

%imabsdiff
%compared = imlincomb(1, imsubtract(tempRadWarp, tempRefDiv), K);