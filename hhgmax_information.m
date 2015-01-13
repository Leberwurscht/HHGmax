% Prints photon energy in eV, ionization potential, ponderomotive energy and
% cutoff position in scaled atomic units, and the Keldysh parameter.
% Also prints a warning if operating in multiphoton ionization regime.
%
% Arguments:
%   config - struct() of the following fields:
%     config.wavelength - driving field wavelength in millimeters
%     config.ionization_potential - in eV
%     config.peak_intensity - peak intensity in W/cm^2
%     config.beam_waist (optional) - beam waist in mm; if provided, Rayleigh
%                                    length will be computed
%   gain (optional) - if given, peak intensity is multiplied with this value
%                     before calculations are done (useful if you want to get
%                     the cutoff at regions of reduced intensity, e.g. off-axis
%                     or outside of the focus)
%
% Return values:
%   information - struct() of the following fields:
%     photon_energy_eV - driving field photon energy in eV
%     ip_SAU - ionization potential in scaled atomic units
%     up_SAU - ponderomotive potential in scaled atomic units
%     cutoff_SAU - cutoff position in scaled atomic units
%     keldysh_parameter - the Keldysh parameter
%     rayleigh_length - Rayleigh length in mm (only if config.beam_waist was
%                       provided)
%

function info_struct = hhgmax_information(config, gain)

if ~exist('gain', 'var')
  gain = 1;
end

c = 299792458;
eps0 = 8.854187817e-12;
m = 9.10938291e-31;
e = 1.602176565e-19;
hbar = 1.054571726e-34;

lambda = config.wavelength*1e-3;

omega = 2*pi*c/lambda;
photon_energy = hbar*omega;
photon_energy_eV = photon_energy / e
ip_SAU = config.ionization_potential / photon_energy_eV

E0_SI = sqrt(2 * gain*config.peak_intensity*1e4 / c / eps0);
	% = sqrt(2*I/c/eps0);
up_SAU = e^2*E0_SI^2/4/m/omega^2 / photon_energy

cutoff_SAU = ip_SAU + 3.17*up_SAU
keldysh_parameter = sqrt(ip_SAU/2/up_SAU)
if keldysh_parameter>1
  warning('Keldysh parameter should be smaller than one (tunnel ionization regime), otherwise Lewenstein model is inaccurate.')
end

info_struct = struct();

if isfield(config,'beam_waist')
  rayleigh_length = 2*pi/config.wavelength *config.beam_waist^2/2
  info_struct.rayleigh_length = rayleigh_length;
end

info_struct.photon_energy_eV = photon_energy_eV;
info_struct.ip_SAU = ip_SAU;
info_struct.up_SAU = up_SAU;
info_struct.cutoff_SAU = cutoff_SAU;
info_struct.keldysh_parameter = keldysh_parameter;
