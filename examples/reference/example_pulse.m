% for executing, copy to main folder or use addpath

% load HHGmax
hhgmax = hhgmax_load();

% setup time axis: 100 driving field periods
t= -50*2*pi : 2*pi/100 : 50*2*pi;

config = struct();
config.wavelength = 1e-3; % mm
config.pulse_duration = 30; % fs
config.pulse_shape = 'cos_sqr';

% compute pulse coefficients
[omega, coefficients] = hhgmax.pulse(t, config);

% plot pulse and spectrum
subplot(2,1,1);
plot(t, real(ifft(conj(coefficients))));
title('pulse');
xlabel('time [s.a.u.]');

subplot(2,1,2);
plot(omega, abs(coefficients).^2);
xlim([0.5,1.5])
title('spectrum');
xlabel('angular frequency [s.a.u.]');
