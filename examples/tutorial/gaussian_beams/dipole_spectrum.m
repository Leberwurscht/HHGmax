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
config.driving_field = 'hhgmax.gh_driving_field';
config.mode = 'TEM00';
config.beam_waist = 0.010; % mm

config.wavelength = 1e-3; % mm
config.peak_intensity = 1e14; % W/cm^2

config.pulse_shape = 'gaussian';
config.pulse_duration = 30; % fs
[pulse_omega, pulse_coefficients] = hhgmax.pulse(t_cmc, config);
config.omega = pulse_omega;
config.pulse_coefficients = pulse_coefficients;

% ionization potential of model atom
config.ionization_potential = 12.13; % eV (for Xe)

% integration settings for Lewenstein model
config.tau_interval_length = 1; % driving field periods
config.tau_window_length = 0.5; % driving field periods
config.t_window_length = 5; % driving field periods

% compute dipole spectrum at different positions
xv = [0 0.005]; yv = 0; zv = [0 0.200];
[omega, response] = hhgmax.dipole_response(t_cmc, xv, yv, zv, config);

% plot dipole responses
for xi=1:2
 for yi=1
  for zi=1:2
    response000 = squeeze(response(yi,xi,zi,1,:));

    subplot(2,2,xi*2+zi-2);
    semilogy(omega, abs(response000).^2);
    title(['x=' num2str(xv(xi)) ', y=' num2str(yv(yi)) ', z=' num2str(zv(zi)) ' [mm]']);
    xlabel('harmonic order');
    ylabel('harmonic yield [arb. units]');
  end
 end
end
