% Calculates the time-dependent driving field E(t_cmc) at a given position, in
% co-moving coordinates, assuming a plane wave propagating in positive z
% direction.
%
% Arguments:
%   x - x value (millimeters)
%   y - y value (millimeters)
%   z - z value (millimeters)
%   config - struct() of the following fields:
%     config.omega - angular frequency axis for the Fourier coefficients
%                    (from -pi/N/dt to +pi/N/dt, needn't be monotonic)
%     config.pulse_coefficients - Fourier coefficients of pulse
%     config.wavelength - wavelength in millimeters
%     config.peak_intensity - peak intensity in W/cm^2
%
% Return values:
%   Et_cmc - driving field E(t_cmc) in scaled atomic units
%
% Example:
%   > config = struct();
%   > config.wavelength = 1e-3;
%   > config.peak_intensity = 1e14;
%   >
%   > t=-30*2*pi:.01:30*2*pi;
%   > [omega, coeff]=hhgmax_pulse(t, struct('wavelength',1e-3, 'pulse_duration',70,...
%   >                                'pulse_shape','gaussian'));
%   > config.omega = omega;
%   > config.pulse_coefficients = coeff;
%   >
%   > Et = hhgmax_plane_wave_driving_field(0, 0, 0, config);
%   > plot(t, real(Et), 'b');
%   > title('Driving field at z=0');
%
function [Et_cmc] = hhgmax_plane_wave_driving_field(x, y, z, config)

% extract and check arguments
omega = config.omega;
pulse_coefficients = config.pulse_coefficients;
if ~(min(omega)<0) || ~(max(omega)>0)
  error('omega axis should go from -pi/N/dt to +pi/N/dt');
end

% compute electric field amplitude in SI units
E0_SI = sqrt(2 * config.peak_intensity*1e4 / 299792458 / 8.854187817e-12);
	% = sqrt(2*I/c/eps0);

% convert it to scaled atomic units
E0 = hhgmax_sau_convert(E0_SI, 'E', 'SAU', config);

% calculate field at (x,y,z) in co-moving coordinates, by inverse Fourier
% transformation of the pulse coefficients
Et_cmc = E0 * ifft(conj(pulse_coefficients), [], 2);
