%% NEUTRONIX

% NEUTRONIX is a Matlab and python based code to process neutron data for
% materials sciences.

% The main tools in Neutronix are :
% - BENRA (Bragg Edge Neutron Radiography Analysis)

%% Startup
clear all;


% Input - General

% Select codes:
toggles.BENRA = 1;
toggles.postprocessing = 1;
toggles.masking = 1;
toggles.adjust = 1;


%% Input - BENRA

% Update to GUI interface



% Wavelength range (angstrom):
input.WaveMin = 2.945;
input.WaveMax = 8.064;

% Temporary Bragg window allocation
values.ABEminN = 1;
values.ABEmaxN = 261;

values.NBEminN = 1980;
values.NBEmaxN = 2000;


% Location of Bragg-Edge (wavelength in angstrom):
input.BraggW = 6.78;

% Precision range (positive range = negative range, in Angstrom):
% Next update: RadRangeSelector will automatically select best range.
input.RadRangeABE = 0.1; % Away Bragg-Edge
input.RadRangeNBE = 0.2; % Near Bragg-Edge

% External Delay (in milliseconds): 
input.ExtDelay = 20;

% Account for summed image (1 if there is a summed image in folder)
toggles.SummedI = 0;

% Registration method (0: Matlab, 1: DaVis);
toggles.DaVis = 0;

% Select Away Bragg-Edge position (0 for self-defined, 1 for auto-selection - curently start of scan)
toggle.StartW = 1;
values.StartW = 2.9;

% Add functions and output folders
addpath('NEUTRONIX/natsortfiles/');


%% Non-user inputs

% Load script versions
database = load('versions.mat');
% versions = database.versions;
% save('versions.mat', 'versions');


%% Code start

if toggles.BENRA == 1
    run(database.versions(2,1))
end


disp('NEUTRONIX - BENRA has completed');
