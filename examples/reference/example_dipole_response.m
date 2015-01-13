% for executing, copy to main folder or use addpath

% load HHGmax
hhgmax = hhgmax_load();

% configure time axis
time_steps = 200; % per period
t_cmc = -40*2*pi : 2*pi/time_steps : 40*2*pi; % 80 periods

% configure spatial grid
xv = [0 0.005]; % mm
yv = [0]; % mm
zv = [0 0.200]; % mm

% configure wavelength
config = struct();
config.wavelength = 1.0e-3; % mm

% configure driving field
 config.driving_field = 'hhgmax.gh_driving_field';

 % basic configuration
 config.peak_intensity = 7e13; % W/cm^2

 % temporal shape
 config.pulse_shape = 'gaussian';
 config.pulse_duration = 100; % fs
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
config.t_window_length = 5;

% we are only interested in harmonics below the 50th
config.cache_omega_ranges = [0 50];

% if we are only interested in 13th and 15th harmonics:
%config.cache_omega_ranges = [12.5 13.5; 14.5 15.5];

% set cache directory
config.cachedir = 'example_dipole_response_cache';

% call dipole_response
[omega, response_cmc] = hhgmax.dipole_response(t_cmc, xv, yv, zv, config);

% plot dipole spectrum at different positions
subplot(2,2,1);
spectrum = squeeze(response_cmc(1,1,1,1,:));
semilogy(omega, abs(spectrum).^2);
ylabel('|dipole moment|^2 [s.a.u.]');
title('x=z=0');

subplot(2,2,2)
spectrum = squeeze(response_cmc(1,1,2,1,:));
semilogy(omega, abs(spectrum).^2);
title('x=0 z=200um')

subplot(2,2,3)
spectrum = squeeze(response_cmc(1,2,1,1,:));
semilogy(omega, abs(spectrum).^2);
xlabel('angular frequency [s.a.u.]');
ylabel('|dipole moment|^2 [s.a.u.]');
title('x=5um z=0')

subplot(2,2,4)
spectrum = squeeze(response_cmc(1,2,2,1,:));
semilogy(omega, abs(spectrum).^2);
xlabel('angular frequency [s.a.u.]');
title('x=5um z=200um')
