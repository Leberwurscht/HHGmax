% Converts quantities from SI units to scaled atomic units and vice versa.
%
% Arguments:
%   value - the value to be converted
%   quantity - the respective physical quantity, as symbol; currently supported
%              are 'E' (electric field), 'U' (energy), 's' (length),
%              'A' (area), 'V' (volume), 't' (time), and 'v' (speed)
%   target - if 'SI', value is converted from SAU to SI; if 'SAU', conversion
%            is done vice versa
%   config - struct() with at least one field:
%     config.wavelength - driving field wavelength in millimeters
%
% Return values:
%   converted - the converted value
%
% Example:
%   > config = struct();
%   > config.wavelength = 1e-3; % mm
%   >
%   > T_SI = hhgmax_sau_convert(2*pi, 't', 'SI', config);
%
function converted = hhgmax_sau_convert(value, quantity, target, config)

% some needed physical constants, in SI units
c = 299792458;
hbar = 1.054571726e-34;
eq = 1.602176565e-19; % electron charge
a0 = 5.2917721092e-11; % Bohr radius
Ry = 13.60569253*eq; % Rydberg unit of energy

% scaled atomic unit quantities expressed in SI units
t_unit_SI = (config.wavelength*1e-3) / c / (2*pi);
omega_unit_SI = 1/t_unit_SI;

U_unit_SI = hbar * omega_unit_SI; % hbar*omega
q_unit_SI = eq;
s_unit_SI = a0 * sqrt(2*Ry/U_unit_SI);
	% [concluded from (23) in Lewenstein paper]
E_unit_SI = U_unit_SI / q_unit_SI / s_unit_SI;
	% [concluded from (2) in Lewenstein paper]

if strcmp(quantity,'E') && strcmpi(target,'SI')
  converted = value * E_unit_SI;
elseif strcmpi(quantity,'E') && strcmpi(target,'SAU')
  converted = value / E_unit_SI;

elseif strcmp(quantity,'U') && strcmpi(target,'SI')
  converted = value * U_unit_SI;
elseif strcmp(quantity,'U') && strcmpi(target,'SAU')
  converted = value / U_unit_SI;

elseif strcmp(quantity,'s') && strcmpi(target,'SI')
  converted = value * s_unit_SI;
elseif strcmp(quantity,'s') && strcmpi(target,'SAU')
  converted = value / s_unit_SI;

elseif strcmp(quantity,'A') && strcmpi(target,'SI')
  converted = value * s_unit_SI^2;
elseif strcmp(quantity,'A') && strcmpi(target,'SAU')
  converted = value / s_unit_SI^2;

elseif strcmp(quantity,'V') && strcmpi(target,'SI')
  converted = value * s_unit_SI^3;
elseif strcmp(quantity,'V') && strcmpi(target,'SAU')
  converted = value / s_unit_SI^3;

elseif strcmp(quantity,'t') && strcmpi(target,'SI')
  converted = value * t_unit_SI;
elseif strcmp(quantity,'t') && strcmpi(target,'SAU')
  converted = value / t_unit_SI;

elseif strcmp(quantity,'v') && strcmpi(target,'SI')
  converted = value * s_unit_SI / t_unit_SI;
elseif strcmp(quantity,'v') && strcmpi(target,'SAU')
  converted = value / (s_unit_SI / t_unit_SI);

else
  error('quantity or target argument invalid');
end
