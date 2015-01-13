% add program directory to search path and load HHGmax
% (you need to adapt path!)
addpath('../../../');
hhgmax = hhgmax_load();

% initialize config struct
config = struct();

% specify time axis
% - we will be able to resolve harmonics up to the 100th,
%   as we have 200=1/0.005 points per driving field period
t_cmc = 2*pi*(-20.000 : 0.005 : 20.000);

% specify non-periodic driving field
config.periodic = 0;

% specify callback function for driving field computation,
% then set required config options for this callback
config.driving_field = 'sech_driving_field';
config.wavelength = 1e-3; % mm
config.t_cmc = t_cmc;
config.amplitude = 2.5e10; % V/m
config.fwhm = 30; % fs

% ionization potential of model atom
config.ionization_potential = 12.13; % eV (for Xe)

% integration settings for Lewenstein model
config.tau_interval_length = 1; % driving field periods
config.tau_window_length = 0.5; % driving field periods
config.t_window_length = 5; % driving field periods

% compute dipole spectrum at x=y=z=0
xv = 0; yv = 0; zv = 0;
[omega, response] = hhgmax.dipole_response(t_cmc, xv, yv, zv, config);
response000 = squeeze(response(1,1,1,1,:));

% plot driving pulse at origin
subplot(2,1,1);
t_fs = hhgmax.sau_convert(t_cmc, 't', 'SI', config)/1e-15;
E_cmc = sech_driving_field(0,0,0, config);
plot(t_fs, real(E_cmc));
title('driving pulse');
xlabel('time [fs]');
ylabel('electric field [arb. units]');

% plot spectrum
subplot(2,1,2);
title('dipole spectrum');
semilogy(omega, abs(response000).^2);
xlabel('harmonic order');
ylabel('harmonic yield [arb. units]');
