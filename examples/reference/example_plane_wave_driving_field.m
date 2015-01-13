% for executing, copy to main folder or use addpath

% load HHGmax
hhgmax = hhgmax_load();

% basic configuration for plane_wave_driving_field
config = struct();
config.wavelength = 1.0e-3; % mm
config.peak_intensity = 7e13; % W/cm^2

% set pulse coefficients (temporal shape)
 % configure time axis (t is in scaled atomic units, i.e. one
 % driving field period equates to 2*pi
 time_steps = 200; % per period
 t = -10*2*pi : 2*pi/time_steps : 10*2*pi; % 20 periods

 % and get spectrum using the hhgmax_pulse.m module
 config.pulse_shape = 'gaussian';
 config.pulse_duration = 20; % fs
 [pulse_omega, pulse_coefficients] = hhgmax.pulse(t, config);

config.omega = pulse_omega;
config.pulse_coefficients = pulse_coefficients;

% compute on-axis driving field at origin and plot it
% (output is in co-moving coordinates)
Et_cmc = hhgmax.plane_wave_driving_field(0, 0, 0, config);

plot(t, real(Et_cmc))
title('driving field at origin')
xlabel('time in co-moving coordinates [scaled atomic units]')
ylabel('driving field amplitude [s.a.u.]')
