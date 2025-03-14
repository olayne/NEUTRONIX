%% INTERXN

% 

% Imports DIC data and interpolate on grid


nScansDIC = nScansNX;


%% PROCESS DIC

% Image resolution
IMRESX = 512;
IMRESY = 512;

% Grid
input.REGxcoords = 1:1:IMRESX;
input.REGycoords = 1:1:IMRESY;


%Read DIC Data from text file
DICExxFileList = dir([input.ExxDICDir '\B00*dat']);
DICEyyFileList = dir([input.EyyDICDir '\B00*dat']);

DICData = cell(1,nScansDIC);

for iScan = 1:nScansDIC
    % Exx
    tmpDICDataExx = importDICDatFile(fullfile(input.ExxDICDir, DICExxFileList(iScan).name));
    tmpDICDataEyy = importDICDatFile(fullfile(input.EyyDICDir, DICEyyFileList(iScan).name));

    % define XRD grid
    [DICData{iScan}.NXx,DICData{iScan}.NXy] = ndgrid(input.NXxcoords, input.NXycoords);
    
    % Check size of Exx DIC dataset for consistency.
    sz = zeros(1,3);
    for i = 1:3
        sz(i) = length(unique(tmpDICDataExx(:,i)));
    end
    CalcNPts = sz(1) * sz(2) * sz(3);
    if CalcNPts ~= size(tmpDICDataExx,1)
        errStrSizeInconsistent = ['DIC Exx data for scan %2i is not consistent. '...
            '%6i points defined out of a calculated %6i .\n'];
        error(errStrSizeInconsistent,iScan,size(tmpDICDataExx,1),CalcNPts)
    end
    
     % Check size of Eyy DIC dataset for consistency.
    sz = zeros(1,3);
    for i = 1:3
        sz(i) = length(unique(tmpDICDataEyy(:,i)));
    end
    CalcNPts = sz(1) * sz(2) * sz(3);
    if CalcNPts ~= size(tmpDICDataEyy,1)
        errStrSizeInconsistent = ['DIC Eyy data for scan %2i is not consistent. '...
            '%6i points defined out of a calculated %6i .\n'];
        error(errStrSizeInconsistent,iScan,size(tmpDICDataEyy,1),CalcNPts)
    end
    
  

    % Reshape x, y, z, Exx, Exy and Eyy data

    DICData{iScan}.X = reshape(tmpDICDataExx(:,1),...
        sz(1), sz(2), sz(3));
    DICData{iScan}.Y = reshape(tmpDICDataExx(:,2),...
        sz(1), sz(2), sz(3));
    DICData{iScan}.Z = reshape(tmpDICDataExx(:,3),...
        sz(1), sz(2), sz(3));
    DICData{iScan}.Exx = reshape(tmpDICDataExx(:,4),...
        sz(1), sz(2), sz(3));
    DICData{iScan}.Eyy = reshape(tmpDICDataEyy(:,4),...
        sz(1), sz(2), sz(3));
end


