% Calculates the complex field amplitude of a given mode.
%
% Arguments:
%   x - the x position in millimeters (or a grid of values)
%   y - the y position in millimeters (or a grid of values)
%   z - the z position in millimeters (or a grid of values)
%   k - the wave number of the mode in 1/mm (or a grid of values) - avoid small values!
%   config - struct() of following fields:
%     config.beam_waist - beam waist in millimeters
%     config.mode_n, config.mode_m, config.mode_coefficients - coefficients of the Gauss-Hermite modes
%     config.mode - one of 'TEM00', 'GH10', 'Donut', '1d-quasi-imaging', '2d-quasi-imaging'; if given,
%                   config.mode_* is ignored.
%     config.rotation (optional) - a rotation matrix that rotates the beam
%
% Return value:
%   field - the complex field amplitude at specified positions and k values
%
% Example:
%   > config = struct();
%   > config.beam_waist = 0.08;
%   > config.mode = 'TEM00';
%   > hhgmax_gh_mode(0, 0, 1, 2*pi/1e-3, config)
%
function field = hhgmax_gh_mode(x,y,z,k,config)

% apply rotation if necessary
if isfield(config, 'rotation')
  assert(size(config.rotation)==[3 3]);

  dims = size(x);
  assert(size(y)==dims);
  assert(size(z)==dims);

  p = [x(:) y(:) z(:)] * config.rotation;
  x = reshape(p(:,1), dims);
  y = reshape(p(:,2), dims);
  z = reshape(p(:,3), dims);
end

% compute spot sizes
w0 = config.beam_waist;

z_R         = k*w0^2/2;                    % Rayleigh length
w           = w0 * sqrt(1+(z./z_R).^2);    % spot size for a Gaussian at the considered position z

% on-axis wavefront ROC
% does the right thing for z=0, i.e. R=Inf, so supress division by zero warning
orig_state = warning('off','all');
R           = z + z_R.^2 ./ z;
warning(orig_state);

% construct mode
if isfield(config, 'mode')
	if strcmpi(config.mode,'TEM00')
		mode_n            = [0];
		mode_m            = [0];
		mode_coefficients = [1];
	elseif strcmpi(config.mode,'GH10')
		mode_n            = [1];
		mode_m            = [0];
		mode_coefficients = [1];
%	elseif strcmpi(config.mode,'Donut') % TODO: these coefficients are wrong
%		mode_n            = [         0         2 ];
%		mode_m            = [         2         0 ];
%		mode_coefficients = [ sqrt(0.5) sqrt(0.5) ];
	elseif strcmpi(config.mode,'1d-quasi-imaging')
		mode_n            = [          0           0 ];
		mode_m            = [          0           4 ];
		mode_coefficients = [ sqrt(3/11) -sqrt(8/11) ];
	elseif strcmpi(config.mode,'2d-quasi-imaging')
		mode_n            = [          0           0           4 ];
		mode_m            = [          0           4           0 ];
		mode_coefficients = [ sqrt(3/11) -sqrt(4/11) -sqrt(4/11) ];
	else
		error('unknown mode name');
	end
else
	mode_n = config.mode_n;
	mode_m = config.mode_m;
	mode_coefficients = config.mode_coefficients;
end

% check arguments
assert(length(mode_n)==length(mode_coefficients))
assert(length(mode_m)==length(mode_coefficients))

% calculate Gauss-Hermite modes and sum up
field = 0;
for mode_i=1:length(mode_coefficients)
	n = mode_n(mode_i);
	m = mode_m(mode_i);
	coefficient = mode_coefficients(mode_i);

	z_f = w0 ./ w .* exp(i*(k*z-(1+n+m)*atan(z./z_R)));
	x_f = hhgmax_hermite(n,sqrt(2)*x./w).*exp(-x.^2./w.^2+i*k.*x.^2./(2*R));
	y_f = hhgmax_hermite(m,sqrt(2)*y./w).*exp(-y.^2./w.^2+i*k.*y.^2./(2*R));

	field = field + coefficient * z_f .* x_f .* y_f;
end
