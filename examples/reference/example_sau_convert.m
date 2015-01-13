% load HHGmax
hhgmax = hhgmax_load();

% set driving field wavelength
config = struct();
config.wavelength = 1e-3; % mm

% convert a time value of 2*pi in scaled atomic units,
% which corresponds to one driving field period, to SI
% units, i.e. to seconds
T_SI = hhgmax.sau_convert(2*pi, 't', 'SI', config)
