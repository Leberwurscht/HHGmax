% add program directory to search path
% (you need to adapt this!)
addpath('../../../');

% initialize config struct
config = struct();

% specify time axis
% - as we use periodic mode, discretize interval (0,2*pi)
% - we will be able to resolve harmonics up to the 100th,
%   as we have 200=1/0.005 points per driving field period
t_cmc = 2*pi*(0 : 0.005 : 0.995);

% use periodic driving field mode
config.periodic = 1;

% specify callback function for driving field computation,
% then set required config options for this callback
config.driving_field = 'plane_wave_driving_field';

config.wavelength = 1e-3; % mm
config.peak_intensity = 1e14; % W/cm^2

[pulse_omega, pulse_coefficients] = pulse(t_cmc, config);
config.omega = pulse_omega;
config.pulse_coefficients = pulse_coefficients;

% ionization potential of model atom
config.ionization_potential = 12.13; % eV (for Xe)

% integration settings for Lewenstein model
config.tau_interval_length = 1; % driving field periods
config.tau_window_length = 0.5; % driving field periods

% compute dipole spectrum at x=y=z=0
xv = 0; yv = 0; zv = 0;
[omega, response] = dipole_response(t_cmc, xv, yv, zv, config);
response000 = squeeze(response(1,1,1,1,:));

% plot spectrum
title('dipole spectrum');
semilogy(omega, abs(response000).^2);
xlabel('harmonic order');
ylabel('harmonic yield [arb. units]');
