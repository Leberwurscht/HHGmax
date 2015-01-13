% Returns a struct with all functions of the HHGmax framework. This is done to
% emulate a namespace.
%
% Arguments: none
%
% Return values:
%   information - struct() containing all functions
%

function function_struct = hhgmax_load()

% modules
function_struct.cache = @hhgmax_cache;
function_struct.dipole_response = @hhgmax_dipole_response;
function_struct.farfield = @hhgmax_farfield;
function_struct.get_omega_axis = @hhgmax_get_omega_axis;
function_struct.gh_driving_field = @hhgmax_gh_driving_field;
function_struct.gh_mode = @hhgmax_gh_mode;
function_struct.harmonic_propagation = @hhgmax_harmonic_propagation;
function_struct.hermite = @hhgmax_hermite;
function_struct.information = @hhgmax_information;
function_struct.lewenstein = @hhgmax_lewenstein;
function_struct.method_syntax_workaround = @hhgmax_method_syntax_workaround;
function_struct.plane_wave_driving_field = @hhgmax_plane_wave_driving_field;
function_struct.pulse = @hhgmax_pulse;
function_struct.reference_low_level = @hhgmax_reference_low_level;
function_struct.sau_convert = @hhgmax_sau_convert;
function_struct.tong_lin_ionization_rate = @hhgmax_tong_lin_ionization_rate;

% classes
function_struct.binary_file_fallback = @hhgmax_binary_file_fallback;
function_struct.binary_file_netcdf = @hhgmax_binary_file_netcdf;
function_struct.cache_file = @hhgmax_cache_file;
function_struct.cache_ram = @hhgmax_cache_ram;
function_struct.reference = @hhgmax_reference;
