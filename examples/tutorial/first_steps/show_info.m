% example for Windows
addpath('C:/HHG_Simulation_Code/');

% OR: example for Linux
%addpath('/home/user/HHG_Simulation_Code/');

% load HHGmax
hhgmax = hhgmax_load();

% print information, amongst others cutoff position, for given settings
config = struct();
config.wavelength = 1e-3; % mm
config.ionization_potential = 12.13; % eV (for Xe)
config.peak_intensity = 1e14; % W/cm^2
hhgmax.information(config);
