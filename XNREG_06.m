%% XNREG_06

%% NIR

% Neutron Radiography Registration

% Input: location of radiography images

% Output: Dispplacement field D


%% Create Summed Images - Away Bragg-Edge (Registration Zone)

SummedImage = cell(1, values.nScansNX);
AveragedImage = cell(1, values.nScansNX);
parfor iScan = 1:values.nScansNX 
    % Load first radiography in range
    tempRad = IMPORTN_01(INDEXN_01(iScan, values.ABEminN, directories, lists));
    tempFlat = IMPORTN_01(INDEXN_01(0, values.ABEminN, directories, lists));
    
    % Remove image aberations and dead pixels
    ripimatmode = 1;
    tempRad = RIPIMAT_04(tempRad, ripimatmode);
    tempFlat = RIPIMAT_04(tempFlat, ripimatmode);
    
    % Remove flat aberations
    meanIntensityValue = mean2(tempFlat);
    tempRadM = imlincomb(meanIntensityValue, tempRad);
    tempRadMC = imdivide(tempRadM, tempFlat);
    
    % Save first iteration
    Image = tempRadMC;
    
    for nRad = (values.ABEminN+1):values.ABEmaxN
        
        % Load radiographies in sequence
        tempRad = IMPORTN_01(INDEXN_01(iScan, nRad, directories, lists));
        tempFlat = IMPORTN_01(INDEXN_01(0, nRad, directories, lists));

        % Remove image aberations and dead pixels
        ripimatmode = 1;
        tempRad = RIPIMAT_04(tempRad, ripimatmode);
        tempFlat = RIPIMAT_04(tempFlat, ripimatmode);

        % Remove flat aberations
        meanIntensityValue = mean2(tempFlat);
        tempRadM = imlincomb(meanIntensityValue, tempRad);
        tempRadMC = imdivide(tempRadM, tempFlat);

        % Add subsequent iterations
        Image = imlincomb(1, Image, 1, tempRadMC);
        %    SummedI{1, iScan} = 0.5*SummedI{1, iScan} + 0.5*tempRadMC;
        %Image = Image + tempRadMC;
    end


SummedImage{1, iScan} = Image;
AveragedImage{1, iScan} = rdivide(Image,values.ABEmaxN);

end

%% Adjusting images
if toggles.adjust == 1
   for iScan = 2:values.nScansNX
        imDiff = SummedImage{1, 1} - SummedImage{1, iScan};
        imSum = SummedImage{1, 1} + SummedImage{1, iScan};  
        percentDiff = 200 * mean(imDiff(:)) / mean(imSum(:));
        SummedImage{1, iScan} = (1 + percentDiff/100) * SummedImage{1, iScan};
        AveragedImage{1, iScan} = rdivide(SummedImage{1, iScan},values.ABEmaxN);
   end
end

%% Image Masking
if toggles.masking == 1
    SummedMasked = cell(1, values.nScansNX);
    AveragedMasked = cell(1, values.nScansNX);
    for iScan = 1:values.nScansNX
        ToMask = SummedImage{1, iScan};
        mask = ToMask >= 36000 & ToMask <= 52000; % Mask of only pixels with GLs of 165 and 166
        ToMask(~mask) = 0; % blacken outside the mask.
        SummedMasked{1, iScan} = ToMask;
        AveragedMasked{1, iScan} = rdivide(SummedMasked{1, iScan},values.ABEmaxN);
    end
end


%% Pre-process
if toggles.masking == 1
    CorrectedAveraged = AveragedMasked;
else
    CorrectedAveraged = AveragedImage;
end

for iScan = 1:values.nScansNX
    ripimatmode = 2;
    tempSummedI = CorrectedAveraged{1, iScan};
    [tempSummedIC] = RIPIMAT_04(tempSummedI, ripimatmode);
    CorrectedAveraged{1, iScan} = tempSummedIC;
end



%% Calculate Vector Fields

RegRef =  CorrectedAveraged{1, 1};
parfor iScan = 1:values.nScansNX
    MovIm = CorrectedAveraged{1, iScan};
    [D, M] = imregdemons(MovIm, RegRef, [100 200 300 400 500 600],'AccumulatedFieldSmoothing', 1.5, 'PyramidLevels', 6);
    DispField{iScan} = D;
    MovingReg{iScan} = M;
end
    

%% BIN
% 
%         tempI = fitsread(fullfile(lists.FullRadScan{iScan}(nRad).folder, lists.FullRadScan{iScan}(nRad).name));
%         tempFlat = fitsread(fullfile(lists.Flats(nRad).folder, lists.Flats(nRad).name));
%         tempI = imrotate(imdivide(tempI, tempFlat), 90);

%    SummedI{iScan} = im2int16(SummedI{iScan}); 
% imlincomb
% fitsread

% SummedIC = cell(1, values.nScansNX); % Define array of corrected summed images
% for iScan = 1:values.nScansNX
%     ripimatmode = 0;
%     tempSummedI = SummedI{iScan};
%     [tempSummedIC] = RIPIMAT_04(tempSummedI, ripimatmode);
%     SummedIC{iScan} = tempSummedIC;
% end