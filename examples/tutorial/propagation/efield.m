% add program directory to search path and load HHGmax
% (you need to adapt path!)
addpath('../../../');
hhgmax = hhgmax_load();

% initialize config struct
config = struct();

% specify time axis
% - as we use periodic mode, discretize interval (0,2*pi)
% - we will be able to resolve harmonics up to the 50th,
%   as we have 100=1/0.01 points per driving field period
t_cmc = 2*pi*(0 : 0.01 : 0.99);

% specify periodic driving field
config.periodic = 1;

% specify callback function for driving field computation,
% then set required config options for this callback
config.driving_field = 'hhgmax.gh_driving_field';
config.mode = 'TEM00';
config.beam_waist = 0.010; % mm

config.wavelength = 1e-3; % mm
config.peak_intensity = 7e13; % W/cm^2

[pulse_omega, pulse_coefficients] = hhgmax.pulse(t_cmc, config);
config.omega = pulse_omega;
config.pulse_coefficients = pulse_coefficients;

% ionization potential of model atom
config.ionization_potential = 12.13; % eV (for Xe)

% integration settings for Lewenstein model
config.tau_interval_length = 1; % driving field periods
config.tau_window_length = 0.5; % driving field periods

% discretization of interaction volume
xv = -0.010:0.0002:0.010; %   20um
yv = -0.010:0.0002:0.010; % x 20um
zv = -0.025:0.005:0.025;  % x 50um

% configuration for harmonic_propagation module
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

% call harmonic_propagation module which will use the dipole_response module
% for calculating dipole spectra
[z_max, omega, U] = hhgmax.harmonic_propagation(t_cmc, xv, yv, zv, config, propagation_config);

% select one harmonic frequency for plotting
omega_i = 22; % corresponds to 21st harmonic
omega = omega(omega_i)
U = squeeze(U(:,:,1,omega_i));

% plot electric field intensity of harmonic radiation
intensity = abs(U).^2;

colormap(fliplr(hot));
imagesc(xv,yv, intensity / max(max(intensity)));
title(['electric field intensity at z=' num2str(z_max) 'mm'])
xlabel('x [mm]')
ylabel('y [mm]')
