% This file implements a callback function for computing the driving field
% which can be used in the place of gh_driving_field or plane_wave_driving_
% field.
%
% It computes a driving field consisting of a superposition of two plane waves
% with slightly different directions. Their k vectors are assumed to lie within
% the x-z-plane, and to be mirror symmetric with respect to the z axis.
% This module is only suitable for producing periodic driving fields, so always
% set config.periodic=1 when calling the dipole_response module.
%
% Arguments:
%   x, y, z - position in millimeters
%   config - struct() of the following fields:
%     config.wavelength - driving field wavelength in millimeters
%     config.t_cmc - co-moving time axis (in scaled atomic units)
%     config.amplitude - electric field amplitude of single plane wave, in
%                        V/m
%     config.theta - angle between k vectors of plane waves, in degree
%
function E_cmc = crossed_waves_driving_field(x, y, z, config)

% load HHGmax to be able to access sau_convert
hhgmax = hhgmax_load();

% convert electric field amplitude to scaled atomic units
E0 = hhgmax.sau_convert(config.amplitude, 'E', 'SAU', config);

% convert co-moving time axis to conventional one
c = 299792458;
delta_t = hhgmax.sau_convert(z*1e-3/c, 't', 'SAU', config);
t = config.t_cmc + delta_t;

% set angular frequency and wave number
omega = 1; % in scaled atomic units
k = 2*pi/config.wavelength; % in 1/mm

% compute the electric field of one plane wave (ky1=0)
kx1 = k*sin(config.theta/180*pi / 2);
kz1 = k*cos(config.theta/180*pi / 2);
E_1 = E0 * exp(i*kx1*x+i*kz1*z - i*omega*t);

% compute the electric field of second plane wave (ky2=0)
kx2 = k*sin(-config.theta/180*pi / 2);
kz2 = k*cos(-config.theta/180*pi / 2);
E_2 = E0 * exp(i*kx2*x+i*kz2*z - i*omega*t);

% compute total electric field
E_cmc = E_1 + E_2;
