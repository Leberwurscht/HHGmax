% This file implements a callback function for computing the driving field
% which can be used in the place of gh_driving_field or plane_wave_driving_
% field.
%
% It computes a plane wave pulse with a sech shape:
%   E(t) = E0 * sech(t/tau) * exp(-i*omega*t)
%
% Arguments:
%   x, y, z - position in millimeters
%   config - struct() of the following fields:
%     config.wavelength - driving field wavelength in millimeters
%     config.t_cmc - co-moving time axis (in scaled atomic units)
%     config.amplitude - electric field amplitude in V/m
%     config.fwhm - full width at half maximum, in fs
%
function E_cmc = sech_driving_field(x, y, z, config)

% load HHGmax to be able to access sau_convert
hhgmax = hhgmax_load();

% convert electric field to scaled atomic units
E0 = hhgmax.sau_convert(config.amplitude, 'E', 'SAU', config);

% compute tau parameter for sech pulse from FWHM
tau_fs = config.fwhm / 1.76;
tau_SAU = hhgmax.sau_convert(tau_fs*1e-15, 't', 'SAU', config);

% compute envelope
envelope = sech(config.t_cmc/tau_SAU);

% in scaled atomic units, the driving field angular frequency is one
omega = 1;

% compute the electric field
E_cmc = E0 * envelope .* exp(-i*omega*config.t_cmc);
