% Calculates the Fourier coefficients of a pulse with given shape, as needed by
% the *_driving_field.m functions.
%
% Arguments:
%   t - time axis, equally spaced, in scaled atomic units
%   config - struct() of the following fields:
%	config.wavelength - wavelength in millimeters
%	config.pulse_duration - duration of pulse (FWHM w.r.t. intensity) in
%                               femtoseconds (only necessary if pulse shape is
%                               not constant)
%	config.pulse_shape (optional) - one of 'constant' (default),
%                                       'gaussian', 'super-gaussian', or
%                                       'cos_sqr'
%       config.carrier (optional) - can be 'cos' (default) or 'exp'
%       config.ellipticity (optional) - if given, an elliptically polarized
%                                      field is computed, and coefficients for
%                                      both components are returned (amplitude
%                                      is corrected so that total pulse power
%                                      is the same as for linear polarization)
%       config.ce_phase (optional) - allows to specify a CE phase
%
% Return values:
%   omega - the angular frequency axis corresponding to the coefficients, from
%           -pi/N/dt to pi/N/dt in non-monotonic order (value 0 comes first)
%   coefficients - the Fourier coefficients of the pulse (dimensionality:
%                  C*length(omega) where C is the number of components (1 for
%                  linear polarization, 2 for elliptical polarization)
%
% Example:
%   > t=-30*2*pi:.01:30*2*pi;
%   > config = struct();
%   > config.wavelength = 1e-3;
%   > config.pulse_duration = 70;
%   > config.pulse_shape = 'cos_sqr';
%   > [omega, coefficients]=hhgmax_pulse(t, config);
%   > plot(t, real(ifft(conj(coefficients))));
%
function [omega, coefficients] = hhgmax_pulse(t, config)

% convert pulse duration from femtoseconds to scaled atomic units
if isfield(config, 'pulse_shape') && ~strcmpi(config.pulse_shape, 'constant')
  fwhm = hhgmax_sau_convert(config.pulse_duration*1e-15, 't', 'SAU', config);

  if t(1)/(fwhm/2) > -2.5
    warning('lower limit of t interval might cut pulse')
  end
  if t(end)/(fwhm/2) < 2.5
    warning('upper limit of t interval might cut pulse')
  end
end

% construct envelope
if ~isfield(config, 'pulse_shape') || strcmpi(config.pulse_shape, 'constant')
	envelope = 1;
elseif strcmpi(config.pulse_shape, 'gaussian')
	tau = fwhm/2/sqrt(log(sqrt(2)));
	envelope = exp(-(t/tau).^2);
elseif strcmpi(config.pulse_shape, 'super-gaussian')
	tau = fwhm/2/sqrt(sqrt(log(sqrt(2))));
	envelope = exp(-(t/tau).^4);
elseif strcmpi(config.pulse_shape, 'cos_sqr')
	tau = fwhm/2/acos(1/sqrt(sqrt(2)));
	envelope = cos(t/tau) .^ 2;
	envelope(t/tau<=-pi/2) = 0;
	envelope(t/tau>=pi/2) = 0;
else
	error('unknown pulse shape');
end

% parse carrier option
if ~isfield(config, 'carrier') || strcmpi(config.carrier, 'cos')
  carrier = @cos;
elseif strcmpi(config.carrier, 'exp')
  carrier = @(x) exp(1i*x);
else
  error('invalid carrier: must be ''cos'' or ''exp''');
end

% compute time-dependent amplitude
if isfield(config,'ce_phase')
	ce_phase = config.ce_phase;
else
	ce_phase = 0;
end

amplitude(1,:) = envelope .* carrier(t+ce_phase);

% add polarization
if isfield(config,'ellipticity')
	ellipticity = config.ellipticity;
	amplitude(2,:) = (1-ellipticity) * envelope .* carrier(t+ce_phase-pi/2);
	amplitude = amplitude / sqrt( 1 + (1-ellipticity)^2 );
end

% setup frequency axis
domega = 2*pi/(t(2)-t(1))/length(t);
temp = (0:length(t)-1);
temp(temp>=ceil(length(temp)/2)) = temp(temp>=ceil(length(temp)/2)) - length(temp);
omega = temp * domega;

% fourier transform
coefficients = conj(fft(conj(amplitude),[],2));
