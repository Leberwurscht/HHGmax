% add program directory to search path and load HHGmax
% (you need to adapt path!)
addpath('../../../');
hhgmax = hhgmax_load();

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
config.driving_field = 'crossed_waves_driving_field';
config.wavelength = 1e-3; % mm
config.t_cmc = t_cmc;
config.amplitude = 1e10; % V/m
config.theta = 1; % degree

% ionization potential of model atom
config.ionization_potential = 12.13; % eV (for Xe)

% integration settings for Lewenstein model
config.tau_interval_length = 1; % driving field periods
config.tau_window_length = 0.5; % driving field periods

% compute dipole spectrum at x=y=z=0 and at x=0.028648mm, where a minimumm is
% to be expected
xv = [0 0.028648]; yv = 0; zv = 0;

[omega, response] = hhgmax.dipole_response(t_cmc, xv, yv, zv, config);
response_origin = squeeze(response(1,1,1,1,:));
response_test = squeeze(response(1,2,1,1,:));

% plot spectrum
subplot(2,1,1);
title('dipole spectrum at origin');
semilogy(omega, abs(response_origin).^2);
xlabel('harmonic order');
ylabel('harmonic yield [arb. units]');

subplot(2,1,2);
title('dipole spectrum at x=0.028648mm, y=z=0');
semilogy(omega, abs(response_test).^2);
xlabel('harmonic order');
ylabel('harmonic yield [arb. units]');
