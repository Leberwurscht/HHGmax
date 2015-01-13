% Computes the dipole response on a spatial grid using hhgmax_dipole_response.m and
% calculates the resulting complex field amplitude in the last z plane.
%
% Note: Only absorption of harmonics is considered, but effects like change
%       of refractive index by the gas and plasma is neglected. Moreover,
%       the divergence of the harmonics over the given z interval is neglected.
%
% Arguments:
%   t_cmc - the time axis in co-moving coordinates, in scaled atomic units,
%           i.e. in units of 1/omega_driving_field (must be equally spaced)
%   xv - array of x values
%   yv - array of y values
%   zv - array of z values
%   dipole_response_config - struct() as described in hhgmax_dipole_response.m;
%                            wavelength field is also used from this file
%                            (note: non-linear polarization is not supported)
%   config - struct() of following fields:
%     config.transmission (optional) - transmission of used gas with respect to
%                                      intensity for a pressure of 30 torr and
%                                      a path of 1 cm versus photon energy at
%                                      the considered temperature, obtained
%                                      e.g. from [1].
%                                      If not given, a transmission of 1 for
%                                      all wavelengths is assumed.
%     config.transmission_photon_energy - photon energy axis for transmission
%                                         data of used gas, in eV (only
%                                         necessary if config.transmission is
%                                         given)
%     config.density - number density of atoms in mm^-3
%     config.pressure (optional) - gas pressure in bar, can be used instead of
%                                  config.density; then the density will be
%                                  computed from the given pressure for a
%                                  temperature of 295 K using the ideal gas
%                                  law, and config.density can be omitted
%     config.nochecks (optional) - if 1, the x/y/z discretization checks are
%                                  disabled for better performance
%   return_omega (optional) - as described in hhgmax_dipole_response.m
%
% Return values:
%   z_max - the z value of the plane in which the field is computed
%   omega - the angular frequency axis for the returned field, in scaled atomic
%           units, i.e. in multiples of the driving field angular frequency
%   U - the complex field amplitude at the specified z plane for each value of
%       omega; the array shape is length(yv) x length(xv) x C x length(omega),
%       where C is the number of electric field components which is >1 for
%       non-linearly polarized driving fields. The output is in conventional
%       coordinates, not in co-moving ones, and in scaled atomic units.
%
% References:
%   [1] http://henke.lbl.gov/optical_constants/gastrn2.html
%
% Example:
%   see PDF documentation

function [z_max,omega,U] = hhgmax_harmonic_propagation(t_cmc, xv, yv, zv, ...
                                                dipole_response_config, config, ...
                                                return_omega)

if ~exist('return_omega','var')
  return_omega = [];
end

if isfield(config,'density')
  density = config.density * 1e9; % convert to meter^-3
else
  % from ideal gas law: p*V = N*k*T => N/V = p/k/T
  % pressure is in bar, density in meter^-3
  density = config.pressure*1e5 / 1.3806488e-23 / 295;
end

if isfield(config,'nochecks') && config.nochecks
  nochecks = config.nochecks;
  warning('Discretization checks for propagation are disabled.');
else
  nochecks = 0;
end

% get absorption data
if isfield(config, 'transmission')
  % convert transmission energy from eV to scaled atomic units
  absorption_omega = hhgmax_sau_convert(config.transmission_energy*1.602176565e-19, 'U', 'SAU', dipole_response_config);

  % convert transmission for 1cm to absorption coefficient in mm^-1
  alpha_30torr = -log(config.transmission)/10;
  torr = 1.3332e-3; % in bar
  reference_density = 30*torr*1e5 / 1.3806488e-23 / 295;
  alpha = alpha_30torr * density/reference_density;
else
  % absorption coefficient==0 over whole omega range
  absorption_omega = [0 1];
  alpha = [0 0];
end

% set up array for complex amplitude in current plane
U = 0;

% initialize progress struct for dipole_response function
progress = struct('points_total', length(xv)*length(yv)*length(zv));

% compute integral of d(omega)*exp(-absorption_coefficient(omega)*( z_max - current_z )) using trapezoidal rule
if length(zv)<2
  % fallback mode if only one z slice is given
  last_z = zv(1) - 2 * 1e-6; % double value to compensate 0.5 in trapezoid formula
  warning('Only one z slice given, therefore target width is not known. Assuming 1nm.')
else
  % set last_z so that first loop iteration makes no contribution, i.e.
  % trapezoid rule is implemented correctly
  last_z = zv(1);
end
last_integrand = 0;
z_max = zv(length(zv));

for z_i=1:length(zv)
  ['harmonic propagation: processing z-slice ' num2str(z_i) ' of ' num2str(length(zv))]

  current_z = zv(z_i);

  % get dipole response in this z plane
  [omega, d, progress] = hhgmax_dipole_response(t_cmc, xv,yv,current_z,...
                                         dipole_response_config, progress, return_omega);
  components = size(d,4);
  if size(d,4)>2
    error('Propagation of 3-dimensionally polarized harmonics not supported.')
  end
  d = reshape(d, [length(yv)*length(xv)*components length(omega)]);

  % interpolate to get absorption data
  absorption_coefficient = interp1(absorption_omega, alpha, omega, 'linear', 'extrap');

  % compute complex refractive index (assuming real part=1 for now)
  k = omega * 2*pi/dipole_response_config.wavelength;
  kappa = absorption_coefficient / 2 ./ k;
  n = 1 + 1i * kappa;

  % compute integrand for this z value (n-1 instead of n because d is in vacuum comoving coordinates)
  current_integrand = d * diag(exp( -1i * (n-1) .* k * current_z ));
    % note: intentionally not using element-wise multiplication but matrix multiplication, as d has two
    %       indices: first one is position, second one is angular frequency

  % n is not defined for omega==0, so set current_integrand = 0 there
  current_integrand(:, omega==0) = 0;

  % warning if phase difference between z slices is too big, i.e. z resolution is insufficient
  if ~nochecks && z_i>1
    anglediff = angle(current_integrand)-angle(last_integrand);
    normalized_anglediff = angle(exp(i*anglediff)); % normalize to -pi to pi interval

    intensity = abs(current_integrand).^2;
    max_intensity = max(max(intensity));
    significant = (intensity > 0.05*max_intensity);
    significant_anglediff = normalized_anglediff .* significant; % discard phase differences for low amplitudes

    max_anglediff = max(max(abs(significant_anglediff)));

    if max_anglediff > 0.2*pi
      warning(['The phase difference between consecutive z slices is too big: ',...
               num2str(max_anglediff/pi), '*pi at z=', num2str(current_z), '. ',...
               'Increase z resolution to make sure that numeric integration works as expected.']);
    end
  end

  % warning if x-y-resolution is not sufficient
  if ~nochecks
    reshaped_integrand = reshape(current_integrand, [length(yv) length(xv) components*length(omega)]);

    anglediff_x = zeros(size(reshaped_integrand));
    anglediff_x(1:end,2:end,:) = diff(angle(reshaped_integrand),1,2);
    normalized_anglediff_x = angle(exp(i*anglediff_x)); % normalize to -pi to pi interval

    anglediff_y = zeros(size(reshaped_integrand));
    anglediff_y(2:end,1:end,:) = diff(angle(reshaped_integrand),1,1);
    normalized_anglediff_y = angle(exp(i*anglediff_y)); % normalize to -pi to pi interval

    intensity = abs(reshaped_integrand).^2;
    max_intensity = max(max(max(intensity)));
    significant = (intensity > 0.05*max_intensity);

    significant_anglediff_x = normalized_anglediff_x .* significant; % discard phase differences for low amplitudes
    significant_anglediff_y = normalized_anglediff_y .* significant; % discard phase differences for low amplitudes

    max_anglediff_x = max(max(max(abs(significant_anglediff_x))));
    max_anglediff_y = max(max(max(abs(significant_anglediff_y))));

    if max_anglediff_x > 0.2*pi
      warning(['The phase difference between two x values is too big: ',...
               num2str(max_anglediff_x/pi), '*pi at z=', num2str(current_z), '. ',...
               'Increase x resolution to make sure that far field can be computed properly.']);
    end

    if max_anglediff_y > 0.2*pi
      warning(['The phase difference between two y values is too big: ',...
               num2str(max_anglediff_y/pi), '*pi at z=', num2str(current_z), '. ',...
               'Increase y resolution to make sure that far field can be computed properly.']);
    end
  end

  % trapezoidal rule
  deltaz = hhgmax_sau_convert(current_z*1e-3-last_z*1e-3, 's', 'SAU', dipole_response_config);
  U = U + 0.5*( last_integrand + current_integrand )*deltaz;
  last_z = current_z;
  last_integrand = current_integrand;
end

% apply correct prefactor of the integral
c_SAU = hhgmax_sau_convert(299792458, 'v', 'SAU', dipole_response_config);
epsilon0_SAU = 1/4/pi;
density_SAU = 1/hhgmax_sau_convert(1/density, 'V', 'SAU', dipole_response_config);

U = U * diag(1i/2/epsilon0_SAU/c_SAU * omega * density_SAU ./ n .* ...
             exp(1i * n .* k * z_max) );

% U is NaN for omega=0, as n is not defined there. As U is proportional to
% omega, we can manually set it to zero there to get rid of the NaNs.
U(:,omega==0) = 0;

% reshape U so that it has indices yi, xi, components, omega_i
U = reshape(U, [length(yv) length(xv) components length(omega)]);
