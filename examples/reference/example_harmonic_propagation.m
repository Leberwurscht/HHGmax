% for executing, copy to main folder or use addpath

% load HHGmax
hhgmax = hhgmax_load();

% configure time axis - only one period as we use periodic mode
time_steps = 70; % per period
t_cmc = 0 : 2*pi/time_steps : 2*pi;
t_cmc = t_cmc(1:end-1);

% configure spatial grid
xv = -.010:0.0002:.010;  % 20 um
yv = -.010:0.0002:.010;  % 20 um
zv = -0.025:0.005:0.025; % 50 um

% configure wavelength
config = struct();
config.wavelength = 1.0e-3; % mm

% configure driving field
 config.driving_field = 'hhgmax.gh_driving_field';

 % basic configuration
 config.peak_intensity = 7e13; % W/cm^2

 % temporal shape
 config.pulse_shape = 'constant'; % optional, is default value
 [pulse_omega, pulse_coefficients] = hhgmax.pulse(t_cmc, config);
 config.omega = pulse_omega;
 config.pulse_coefficients = pulse_coefficients;

 % spatial shape
 config.mode = 'TEM00';
 config.beam_waist = 0.010; % mm

% set ionization potential for a Xe atom
config.ionization_potential = 12.13; % eV

% configure tau window and t window
config.tau_interval_length = 1;
config.tau_window_length = 0.5;

% activate periodic mode
config.periodic = 1;

% we are only want to plot harmonic 21
config.omega_ranges = [21-0.1 21+0.1];

% set cache directory
config.cachedir = 'example_harmonic_propagation_cache';

% configuration for harmonic propagation
 propagation_config = struct();
 propagation_config.pressure = 0.1; % bar

 % set absorption data:
 % xenon_abs.dat is the file downloaded from
 % http://henke.lbl.gov/optical_constants/gastrn2.html
 % (first two lines commented out with %)
 load('xenon_abs.dat');
 propagation_config.transmission_energy = xenon_abs(:,1);
     % photon energy in eV
 propagation_config.transmission = xenon_abs(:,2);
     % for 30 torr, 1 cm

% call harmonic_propagation
[z_max, omega, U] = hhgmax.harmonic_propagation(t_cmc, xv, yv, zv, config, propagation_config);

% plot electric field amplitude of harmonic radiation
% - due to config.cache_omega_ranges and using periodic mode, the
%   omega_i index of U is one-dimensional, so we can use
%   squeeze to get a 2d array
intensity = abs(squeeze(U)).^2;

imagesc(xv,yv, intensity / max(max(intensity)))
title(['electric field intensity at z=' num2str(z_max) 'mm'])
xlabel('x [mm]')
ylabel('y [mm]')
