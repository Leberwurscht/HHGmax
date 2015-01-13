% Calculates the time-dependent driving field E(t_cmc) at a given position for
% a superposition of Gauss-Hermite modes, using hhgmax_gh_mode.m.
%
% Arguments:
%   x - x value (millimeters)
%   y - y value (millimeters)
%   z - z value (millimeters)
%   config - struct() of the following fields:
%     config.wavelength - wavelength in millimeters
%     config.peak_intensity - peak intensity of corresponding Gaussian beam in
%                             W/cm^2
%     config.omega - angular frequency axis for the Fourier coefficients
%                    (from -pi/N/dt to +pi/N/dt, needn't be monotonic)
%     config.pulse_coefficients - Fourier coefficients of pulse
%     + the config fields mentioned in hhgmax_gh_mode.m
%
% Return values:
%   Et_cmc - complex driving field E(t_cmc) in comoving coordinates and scaled
%            atomic units; first index gives electric field vector component
%            and second corresponds to time axis
%
% Example:
%   > config = struct();
%   > config.wavelength = 1e-3;
%   > config.peak_intensity = 1e14;
%   > config.beam_waist = 0.08;
%   > config.mode = 'TEM00';
%   >
%   > t=-30*2*pi:.01:30*2*pi;
%   > [omega, coeff]=hhgmax_pulse(t, struct('wavelength',1e-3, 'pulse_duration',70));
%   > config.omega = omega;
%   > config.pulse_coefficients = coeff;
%   >
%   > Et0 = hhgmax_gh_driving_field(0, 0, 0, config);
%   > Et30 = hhgmax_gh_driving_field(0, 0, 30, config);
%   > plot(t,real(Et0),'b', t,real(Et30),'r');
%   > legend('Driving field at z=0', 'Driving field at z=30mm');
%
function [Et_cmc] = hhgmax_gh_driving_field(x, y, z, config)

% extract and check arguments
omega = config.omega;
pulse_coefficients = config.pulse_coefficients;
if ~(min(omega)<0) || ~(max(omega)>0)
  error('omega axis should go from -pi/N/dt to +pi/N/dt');
end

% compute k (for vacuum, in 1/mm) from omega (which is in multiples of driving
% field angular frequency)
k = 2*pi/config.wavelength * omega;

% set refractive index (in a later version, the user can supply n(omega) and we
% can interpolate to get an array with the same size as omega)
n = 1;

% compute electric field amplitude in SI units
E0_SI = sqrt(2 * config.peak_intensity*1e4 / 299792458 / 8.854187817e-12);
	% = sqrt(2*I/c/eps0);

% convert it to scaled atomic units
E0 = hhgmax_sau_convert(E0_SI, 'E', 'SAU', config);

% calculate field at (x,y,z) in comoving coordinates
%   note: What we want to do here is the inverse FFT for real output data where
%         it is sufficient to only consider non-negative frequencies in the
%         input data. Matlab does not provide a function for this, so we use
%         normal ifft and set the fourier coefficients for negative frequencies
%         as the conjugated coefficients for positive frequencies.
%         pulse_coefficients is already prepared like that, as is exp(-i*k*z).
%         What remains to be done is A_nm:
A_nm(1:length(k)) = 0;
A_nm(k>0) = hhgmax_gh_mode(x, y, z, n .* k(k>0), config);
A_nm(k<0) = conj(hhgmax_gh_mode(x, y, z, n .* abs(k(k<0)), config));

components = size(pulse_coefficients, 1);
Et_cmc = E0 * ifft(conj(pulse_coefficients .* repmat(A_nm .* exp(-i*k*z), components, 1)), [], 2);
