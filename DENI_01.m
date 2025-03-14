%% DENI_01
% Data Exporter for Neutron Imaging


%% Export post-processed images

% Original set for correlation
for iScan = 1:values.nScansNX   
    % Adjust grayscale
    I = CorrectedAveraged{1, iScan};
    K = I(I>30);
    S = stretchlim(K);
    J = imadjust(I,S,[]);
    % Write to file in results folder
    imwrite(J, [pwd strcat('\Results\', 'Scan n°', num2str(iScan), ' - Corrected Image Correlation.png' )]);      
end

% Difference images corrected
for iScan = 2:values.nScansNX   
    % Adjust grayscale
    I = CorrectedAveragedDiff{1, iScan};
    K = I(I>10);
    S = stretchlim(K);
    J = imadjust(I,S,[]);
    % Write to file in results folder
    imwrite(J, [pwd strcat('\Results\', 'Scan n°', num2str(iScan), ' - Corrected Bragg Difference Reference.png' )]);      
end

% Full images corrected
for iScan = 1:values.nScansNX   
    % Adjust grayscale
    I = CorrectedAveragedFull{1, iScan};
    K = I(I>5);
    S = stretchlim(K);
    J = imadjust(I,S,[]);
    % Write to file in results folder
    imwrite(J, [pwd strcat('\Results\', 'Scan n°', num2str(iScan), ' - Corrected Bragg Full.png' )]);      
end



% Difference cropped
for iScan = 1:values.nScansNX  
    FinalCrop{iScan} = imcrop(CorrectedAveragedDiff{iScan}, [200 300 90 80]);
    % Adjust grayscale
    I = FinalCrop{iScan};
    K = I(I>5);
    S = stretchlim(K);
    J = imadjust(I,S,[]);
    % Write to file in results folder
    imwrite(J, [pwd strcat('\Results\', 'Scan n°', num2str(iScan), ' - Corrected Difference Crop.png' )]);      
end

%% BIN
% Implement TIFF Stacks
% Add experiment number in export