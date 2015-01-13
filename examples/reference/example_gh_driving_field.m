% for executing, copy to main folder or use addpath

% load HHGmax
hhgmax = hhgmax_load();

% basic configuration for gh_driving_field
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

% set mode (spatial shape)
%  - for details see documentation of hhgmax_gh_mode.m -
% note: by default, the optical axis is the z axis
config.mode = 'TEM00';
config.beam_waist = 0.010; % mm

% compute on-axis driving field at two different z positions
% and plot it (output is in co-moving coordinates)
Et_cmc_0mm = hhgmax.gh_driving_field(0, 0, 0, config);
Et_cmc_1mm = hhgmax.gh_driving_field(0, 0, 1, config);

plot(t, real(Et_cmc_0mm), t, real(Et_cmc_1mm))
legend('driving field at z=0mm','driving field at z=1mm')
xlabel('time in co-moving coordinates [scaled atomic units]')
ylabel('driving field amplitude [s.a.u.]')
