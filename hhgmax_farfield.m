% Calculates the far field of the harmonics in a specified plane.
%
% Arguments:
%   xv - row array of x values for the input plane, in mm
%   yv - row array of y values for the input plane, in mm
%   z_U - z position of the input plane, in mm
%   omega - the angular frequency axis for the input field, in scaled atomic
%           units, i.e. in multiples of the driving field angular frequency
%   U - the complex field amplitude at the input z plane for each value of
%       omega; the array shape is length(yv) x length(xv) x C x length(omega),
%       where C is the number of electric field components which must be
%       smaller than 3. The field amplitude must be given in conventional
%       coordinates, not in co-moving ones, and in scaled atomic units.
%   config - struct() of following fields:
%     config.wavelength - driving field wavelength in millimeters
%     config.plane_x - x component a of output meshgrid
%     config.plane_y - y component a of output meshgrid
%     config.padding_x (optional) - if specified, the input data is zero padded
%                                   in x direction to cover the interval
%                                   (start,end); format is [start, end].
%     config.padding_y (optional) - if specified, the input data is zero padded
%                                   in y direction to cover the interval
%                                   (start, end); format is [start, end].
%     config.plane_theta (optional) - rotation of output plane around x axis
%     config.plane_phi (optional) - rotation of output plane around y axis
%     config.plane_psi (optional) - rotation of output plane around z axis
%     config.plane_distance - distance of output plane from origin (focus)
%     config.nochecks (optional) - by default, it is checked whether padding is
%                                  sufficient by comparing phases of adjacent
%                                  points in Fourier space; with nochecks=1,
%                                  these checks can be disabled for better
%                                  performance
%
% Return values:
%   E_plane - complex field amplitude in the output plane for each value of
%       omega and each electric field component; the array shape is
%          length(omega) x C x size(config.plane_y,1) x size(config.plane_x,2)
%       The output is in scaled atomic units.
%
% Example:
%   see PDF documentation

function [E_plane] = hhgmax_farfield(xv,yv,z_U,omega,U, config)

% setup rotation matrix R for screen plane
R = eye(3);
degree = pi/180;

if isfield(config,'plane_theta') % rotation around x axis
  s = sin(config.plane_theta*degree);
  c = cos(config.plane_theta*degree);
  R = R * [1 0 0; 0 c s; 0 -s c];
end

if isfield(config,'plane_phi') % rotation around y axis
  s = sin(config.plane_phi*degree);
  c = cos(config.plane_phi*degree);
  R = R * [c 0 -s; 0 1 0; s 0 c];
end

if isfield(config,'plane_psi') % rotation around z axis
  s = sin(config.plane_psi*degree);
  c = cos(config.plane_psi*degree);
  R = R * [c s 0; -s c 0; 0 0 1];
end

% check xv and yv
if size(xv,2)~=length(xv)
  error('xv must be a row vector')
end
if size(yv,2)~=length(yv)
  error('yv must be a row vector')
end

% apply zero padding to xv and yv axes
dx = xv(2) - xv(1);
dy = yv(2) - yv(1);

if isfield(config,'padding_x')
  x1 = config.padding_x(1);
  x2 = config.padding_x(2);
  assert(x1<xv(1) && x2>xv(end))

  before = fliplr( xv(1):-dx:x1 );
  after = xv(1):dx:x2;
  x_i_start = length(before);
  x_i_end = length(before)+length(xv)-1;
  xv = [before, after(2:end)];
else
  x_i_start = 1;
  x_i_end = length(xv);
end

if isfield(config,'padding_y')
  y1 = config.padding_y(1);
  y2 = config.padding_y(2);
  assert(y1<yv(1) && y2>yv(end))

  before = fliplr( yv(1):-dy:y1 );
  after = yv(1):dy:y2;
  y_i_start = length(before);
  y_i_end = length(before)+length(yv)-1;
  yv = [before, after(2:end)];
else
  y_i_start = 1;
  y_i_end = length(yv);
end

% setup reciprocal space axes and use them to construct a meshgrid
dkx = 2*pi/dx/length(xv);
dky = 2*pi/dy/length(yv);

temp = fftshift(0:length(xv)-1);
temp(temp>=temp(1)) = temp(temp>=temp(1)) - length(xv);
kxv = temp * dkx;

temp = fftshift(0:length(yv)-1);
temp(temp>=temp(1)) = temp(temp>=temp(1)) - length(yv);
kyv = temp * dky;

[kx, ky] = meshgrid(kxv, kyv);

% configure discretization checks
if isfield(config,'nochecks') && config.nochecks
  nochecks = config.nochecks;
  warning('Discretization checks are disabled.');
else
  nochecks = 0;
end

% compute the position of the plane's meshgrid points in 3d coordinate system
x = R(1,1)*config.plane_x + R(1,2)*config.plane_y + R(1,3)*config.plane_distance;
y = R(2,1)*config.plane_x + R(2,2)*config.plane_y + R(2,3)*config.plane_distance;
z = R(3,1)*config.plane_x + R(3,2)*config.plane_y + R(3,3)*config.plane_distance - z_U;
r = sqrt(x.^2 + y.^2 + z.^2);

% get number of electric field components
C = size(U,3);
if C>2
  error('Far field of 3-dimensionally polarized fields not supported.');
end

% preallocate memory for output
E_plane = zeros([length(omega) C size(config.plane_x)]);

for omega_i=1:length(omega)
  disp(['farfield: processing frequency ' num2str(omega(omega_i)) ' (' num2str(omega_i) '/' num2str(length(omega)) ')']);

  for component=1:C
    k = 2*pi/config.wavelength * omega(omega_i);

    % apply zero padding to data
    U_padded = zeros([length(yv) length(xv)]);
    U_padded(y_i_start:y_i_end, x_i_start:x_i_end) = squeeze(U(:,:,component,omega_i));

    % calculate 2d Fourier transformation of harmonic field, with centered zero
    % value in both reciprocal and original space
    F = fftshift(fft2(ifftshift( U_padded ))) * dx/2/pi * dy/2/pi;

    % check if phase oscillates too fast in reciprocal space
    if ~nochecks
      anglediff_x = zeros(size(F));
      anglediff_x(1:end,2:end) = diff(angle(F),1,2);
      normalized_anglediff_x = angle(exp(i*anglediff_x)); % normalize to -pi to pi interval

      anglediff_y = zeros(size(F));
      anglediff_y(2:end,1:end) = diff(angle(F),1,1);
      normalized_anglediff_y = angle(exp(i*anglediff_y)); % normalize to -pi to pi interval

      intensity = abs(F).^2;
      max_intensity = max(max(max(intensity)));
      significant = (intensity > 0.05*max_intensity);

      significant_anglediff_x = normalized_anglediff_x .* significant; % discard phase differences for low amplitudes
      significant_anglediff_y = normalized_anglediff_y .* significant; % discard phase differences for low amplitudes

      max_anglediff_x = max(max(abs(significant_anglediff_x)));
      max_anglediff_y = max(max(abs(significant_anglediff_y)));

      if max_anglediff_x > 0.33*pi
        warning(['The phase difference between two k_x values is too big: ',...
                 num2str(max_anglediff_x/pi), '*pi at omega=', num2str(omega(omega_i)),'. '...
                 'Use (more) zero padding in x direction to make sure that interpolation in reciprocal space works.']);
      end

      if max_anglediff_y > 0.33*pi
        warning(['The phase difference between two k_y values is too big: ',...
                 num2str(max_anglediff_y/pi), '*pi at omega=', num2str(omega(omega_i)),'. ',...
                 'Use (more) zero padding in y direction to make sure that interpolation in reciprocal space works.']);
      end
    end

    % (2.2) from http://en.wikipedia.org/w/index.php?title=Fourier_optics&oldid=557985220#The_far_field_approximation_and_the_concept_of_angular_bandwidth
    % but with different signs because we use the exp(ikr-iwt) convention
    E_plane(omega_i,component,:,:) = -2*pi*1i * k*z./r .* exp(i*k*r)./r ...
                                   .* interp2(kx,ky,F, x./r*k, y./r*k);
  end
end
