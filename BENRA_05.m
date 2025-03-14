%% NEUTRONIX - BENRA

% Bragg Edge Neutron Radiography Analysis (BENRA)


toggles.DaVis = 0;

%% Load Parameters

input.WorkingDir = uigetdir(path, 'Select Working Directory');

% Input Radiography Folder File
directories.Radio = uigetdir(input.WorkingDir, 'Select Radiography Folder (each step including must be in a subfolder, in order)');
directories.OB = uigetdir(input.WorkingDir, 'Select Open Beam Folder (Flat)');

% Input directory for raw DIC data
if toggles.DaVis == 1
    
    directories.ExxDIC = uigetdir(input.WorkingDir, 'Select Exx DIC Data');
    directories.EyyDIC = uigetdir(input.WorkingDir, 'Select Eyy DIC Data');
end


%% Setup


% Query number of scans and list subfolders
directories.RadioFullList = dir(directories.Radio);
values.nScansNX = sum([directories.RadioFullList(~ismember({directories.RadioFullList.name},{'.','..'})).isdir]);
directories.ScanFolders = directories.RadioFullList(~ismember({directories.RadioFullList.name},{'.','..'}));

% Query number of images and check consistency
values.nRadNX = length(dir(fullfile(directories.ScanFolders(1).folder, directories.ScanFolders(1).name, '*.tiff')));
if toggles.SummedI == 1
    values.nRadNX = values.nRadNX-1; % Removing the summed image from counting
end
for iScan = 2:values.nScansNX
    variables.nRadScan = length(dir(fullfile(directories.ScanFolders(iScan).folder, directories.ScanFolders(iScan).name, '*.tiff')));
    if toggles.SummedI == 1
    variables.nRadScan = variables.nRadScan-1;
    end
    if variables.nRadScan == values.nRadNX
        disp('Data consistent, proceeding');
        
    else
        disp('Data Inconsistent : TERMINATING');
        return
    end
end
disp(['Your scans have ', num2str(values.nRadNX), ' radiographies']);

% Define list of scans
for iScan = 1:values.nScansNX
    UnsortedDir = dir(fullfile(directories.ScanFolders(iScan).folder, directories.ScanFolders(iScan).name, '*.tiff'));
    SortedDir = natsortfiles({UnsortedDir.name});
    lists.FullRadScan{iScan} = UnsortedDir;
    lists.FullRadScanSorted{iScan} = SortedDir;
    if toggles.SummedI == 1
    lists.FullRadScan{iScan} = lists.FullRadScan{iScan}(1:values.nRadNX); % Removing summed image - needs update   
    end
end

% Check and process flats
values.nFlats = length(dir(fullfile(directories.OB, '*.tiff')));
if toggles.SummedI == 1
    values.nFlats = values.nFlats-1; % Removing the summed image from counting
end
if values.nFlats == values.nRadNX
    disp('Flats are consistent');
else
    disp('Flats are inconsistent : TERMINATING');
    return
end
disp(['Your have ', num2str(values.nFlats), ' validated open beam radiographies']);

UnsortedFlats = dir(fullfile(directories.OB, '*.tiff'));
SortedFlats = natsortfiles({UnsortedFlats.name});
lists.Flats = UnsortedFlats;
lists.FlatsSorted = SortedFlats;
if toggles.SummedI == 1
   lists.Flats = lists.Flats(1:values.nFlats);  
end

%% Bug needs correction
% Define conversion factor
%values.ConvF = input.WaveMax / values.nRadNX;
%values.BraggN = round((input.BraggW - input.WaveMin) / values.ConvF);
% Next Update: Automatic Range Selector
%values.RadRangeABEN = round(input.RadRangeABE / values.ConvF);
%values.RadRangeNBEN = round(input.RadRangeNBE / values.ConvF);

% Image range in Angstrom ABE (Away Bragg-Edge):
%values.ABEminN = 1;
%values.ABEmaxN = 2* values.RadRangeABEN;

% Wavelenght range in Angstrom NBE (Near Bragg-Edge):
% values.NBEminN = values.BraggN - values.RadRangeNBEN;
% values.NBEmaxN = values.BraggN + values.RadRangeNBEN;

%values.NBEminN = values.BraggN - 2 * values.RadRangeNBEN;
%values.NBEmaxN = values.BraggN;





%% Obtain Displacement Fields

if toggles.DaVis == 1
    run INTERXN_02
else
    run XNREG_05
end




%% Reagister and create Summed Images - Near Bragg-Edge

run NICAP_03

%% Save

    for iScan = 1:values.nScansNX
        V = CorrectedAveragedDiff{iScan};
        filepath = fullfile(directories.Radio, num2str(iScan));
        imwrite(V, filepath + ".tiff");
    end


