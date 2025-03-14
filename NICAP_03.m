%% NICAP_03
% Neutron Image Collation And Processing

SummedFull = cell(1, values.nScansNX);
SummedDiff = cell(1, values.nScansNX);
parfor iScan = 1:values.nScansNX
    % Load first radiography in range
    tempRad = IMPORTN_01(INDEXN_01(iScan, values.NBEminN, directories, lists));
    tempFlat = IMPORTN_01(INDEXN_01(0, values.NBEminN, directories, lists));
    tempRef = IMPORTN_01(INDEXN_01(1, values.NBEminN, directories, lists));
    
    % Retrieve Displacement Field
%    DispField = DispField{iScan};
    
    % Remove image aberations and dead pixels
    ripimatmode = 1;
    tempRad = RIPIMAT_04(tempRad, ripimatmode);
    tempFlat = RIPIMAT_04(tempFlat, ripimatmode);
    tempRef = RIPIMAT_04(tempRef, ripimatmode);
    
    % Process first set
    [tempFull, tempDiff] = RIAD_02(tempRad, tempFlat, tempRef, DispField{iScan}); 
    
    % Post-processing
    ripimatmode = 0;
    tempFull = RIPIMAT_04(tempFull, ripimatmode);
    tempDiff = RIPIMAT_04(tempDiff, ripimatmode);
    
    % Assign first iteration to cell array
    Full = tempFull;
    Diff = tempDiff;
    
    % Enter continuation loop
    for nRad = (values.NBEminN+1):values.NBEmaxN
        % Load subsequent FITS files
        tempRad = IMPORTN_01(INDEXN_01(iScan, nRad, directories, lists));
        tempFlat = IMPORTN_01(INDEXN_01(0, nRad, directories, lists));
        tempRef = IMPORTN_01(INDEXN_01(1, nRad, directories, lists));
        
        % Remove image aberations and dead pixels
        ripimatmode = 1;
        tempRad = RIPIMAT_04(tempRad, ripimatmode);
        tempFlat = RIPIMAT_04(tempFlat, ripimatmode);
        tempRef = RIPIMAT_04(tempRef, ripimatmode);
        
        % Process set
        [tempFull, tempDiff] = RIAD_02(tempRad, tempFlat, tempRef, DispField{iScan});
        
        % Post-processing
        ripimatmode = 0;
        tempFull = RIPIMAT_04(tempFull, ripimatmode);
        tempDiff = RIPIMAT_04(tempDiff, ripimatmode);
        
        % Concatenate sequence
        Full = imlincomb(1, Full, 1, tempFull);
        Diff = imlincomb(1, Diff, 1, tempDiff);

    end
    
    
    SummedFull{iScan} = Full;
    SummedDiff{iScan} = Diff;
    Range = values.NBEmaxN - values.NBEminN;
    AveragedFull{iScan} = rdivide(SummedFull{iScan}, Range);
    AveragedDiff{iScan} = rdivide(SummedDiff{iScan}, Range);
  
    
    disp('Image Registration and Concatenation Completed');
end


%% Adjusting images
if toggles.adjust == 1
   for iScan = 2:values.nScansNX
        imDiff = SummedFull{1, 1} - SummedFull{1, iScan};
        imSum = SummedFull{1, 1} + SummedFull{1, iScan};  
        percentDiff = 200 * mean(imDiff(:)) / mean(imSum(:));
        SummedFull{1, iScan} = (1 + percentDiff/100) * SummedFull{1, iScan};
        Range = values.NBEmaxN - values.NBEminN;
        AveragedFull{1, iScan} = rdivide(SummedFull{1, iScan}, Range);
   end
end

%% Image Masking
%{
if toggles.masking == 1
    SummedFullMasked = cell(1, values.nScansNX);
    AveragedFullMasked = cell(1, values.nScansNX);
    for iScan = 1:values.nScansNX
        ToMask = SummedFull{1, iScan};
        mask = ToMask >= 990 & ToMask <= 1790; % Mask of only pixels with GLs of 165 and 166
        ToMask(~mask) = 0; % blacken outside the mask.
        SummedFullMasked{1, iScan} = ToMask;
        Range = values.NBEmaxN - values.NBEminN;
        AveragedFullMasked{1, iScan} = rdivide(SummedFullMasked{1, iScan}, Range);
    end
end
%}
%% SmartMask
if toggles.masking == 1
    SummedFullMasked = cell(1, values.nScansNX);
    AveragedFullMasked = cell(1, values.nScansNX);
    for iScan = 1:values.nScansNX
        ToMask = SummedFull{1, iScan};
        Calc = CorrectedAveraged{1};
        Mask = im2double(imdivide(Calc,Calc));
        Masked = immultiply(ToMask, Mask);
        SummedFullMasked{1, iScan} = Masked;
        Range = values.NBEmaxN - values.NBEminN;
        AveragedFullMasked{1, iScan} = rdivide(SummedFullMasked{1, iScan}, Range);
        
        ToMask = SummedDiff{1, iScan};
        Masked = immultiply(ToMask, Mask);
        SummedDiffMasked{1, iScan} = Masked;
        Range = values.NBEmaxN - values.NBEminN;
        AveragedDiffMasked{1, iScan} = rdivide(SummedDiffMasked{1, iScan}, Range);
    end
end



%% Post-processing 

if toggles.postprocessing == 1

    if toggles.masking == 1
        CorrectedSummedFull = SummedFullMasked;
        CorrectedAveragedFull = AveragedFullMasked;
        CorrectedSummedDiff = SummedDiffMasked;
        CorrectedAveragedDiff = AveragedDiffMasked;
    else
        CorrectedSummedFull = SummedFull;
        CorrectedAveragedFull = AveragedFull;
        CorrectedAveragedDiff = AveragedDiff;
        CorrectedSummedDiff = SummedDiff;
    end
    
    for iScan = 1:values.nScansNX
         %Averaged Images    
        ripimatmode = 5;
        tempSummedFull = CorrectedAveragedFull{iScan};
        tempSummedDiff = CorrectedAveragedDiff{iScan};
        [tempProcessedFull] = RIPIMAT_04(tempSummedFull, ripimatmode);
        [tempProcessedDiff] = RIPIMAT_04(tempSummedDiff, ripimatmode);
        CorrectedAveragedFull{iScan} = tempProcessedFull;
        CorrectedAveragedDiff{iScan} = tempProcessedDiff;       



        % Summed Images    
        ripimatmode = 3;
        tempSummedFull = CorrectedSummedFull{iScan};
        tempSummedDiff = CorrectedSummedDiff{iScan};
        [tempProcessedFull] = RIPIMAT_04(tempSummedFull, ripimatmode);
        [tempProcessedDiff] = RIPIMAT_04(tempSummedDiff, ripimatmode);
        CorrectedSummedFull{iScan} = tempProcessedFull;
        CorrectedSummedDiff{iScan} = tempProcessedDiff; 
    end
end

%% BIN

% SummedNI = cell(1, 6);
% parfor iScan = 2:values.nScansNX
%     tempI = fitsread(fullfile(lists.FullRadScan{iScan}(values.NBEminN).folder, lists.FullRadScan{iScan}(values.NBEminN).name));
%     tempFlat = fitsread(fullfile(lists.Flats(values.NBEminN).folder, lists.Flats(values.NBEminN).name));
%     tempI = imdivide(tempI, tempFlat);
%     tempIRot = imrotate(tempI, 90);
%     tempIRotReg = imwarp(tempIRot, DispField{iScan});
%     tempRef = fitsread(fullfile(lists.FullRadScan{1}(values.NBEminN).folder, lists.FullRadScan{1}(values.NBEminN).name));
%     tempRef = imdivide(tempRef, tempFlat);
%     tempRefRot = imrotate(tempRef, 90);
%     SummedNI{iScan} = imabsdiff(tempIRotReg, tempRefRot);   
%     for nRad = (values.NBEminN+1):values.NBEmaxN
%         tempI = fitsread(fullfile(lists.FullRadScan{iScan}(nRad).folder, lists.FullRadScan{iScan}(nRad).name));
%         tempFlat = fitsread(fullfile(lists.Flats(nRad).folder, lists.Flats(nRad).name));
%         tempI = imdivide(tempI, tempFlat);
%         tempIRot = imrotate(tempI, 90);
%         tempIRotReg = imwarp(tempIRot, DispField{iScan});
%         tempRef = fitsread(fullfile(lists.FullRadScan{1}(nRad).folder, lists.FullRadScan{1}(nRad).name));
%         tempRef = imdivide(tempRef, tempFlat);
%         tempRefRot = imrotate(tempRef, 90);
%         tempComb = imabsdiff(tempIRotReg, tempRefRot);
%         SummedNI{iScan} = imlincomb(1, SummedNI{iScan}, 1, tempComb);
%     end
% %    SummedI{iScan} = im2int16(SummedI{iScan}); 
% end
% %SummedNI{iScan} = im2int16(SummedNI{iScan}); 
% 
% %% Post-Processing
% if toggles.postprocessing == 1
%     for iScan = 1:values.nScansNX
%         % Post-process images
%     ripimatmode = 0;
%     tempSummedFull = SummedFull{iScan};
%     tempSummedDiff = SummedDiff{iScan};
%     [tempProcessedFull] = RIPIMAT_04(tempSummedFull, ripimatmode);
%     [tempProcessedDiff] = RIPIMAT_04(tempSummedDiff, ripimatmode);
%     SummedFull{iScan} = tempProcessedFull;
%     SummedDiff{iScan} = tempProcessedDiff;  
%     end
% end
