% Calculates the fourier-transformed dipole response on a spatial grid, using the
% Lewenstein model as implemented in hhgmax_lewenstein.cpp.
%
% Parameters:
%   t_cmc - the time axis in comoving coordinates, in scaled atomic units,
%           i.e. in units of 1/omega_driving_field (must be equally spaced)
%   xv - array of x values
%   yv - array of y values
%   zv - array of z values
%   config - struct() of following fields:
%     config.wavelength - driving field wavelength in millimeters
%     config.driving_field - name of a .m file (without the .m) containing a
%                            function driving_field(x,y,z,config) that
%                            calculates the time-dependent driving field
%                            (note: not using function handle in order to
%                            maintain octave compatibility, which does not
%                            support isequal on function handles until 3.4)
%     config.precomputed_driving_field -
%       name of a folder, containing precomputed data for the driving field; if
%       given, the option config.driving_field is ignored and can be omitted.
%       The folder must contain a file called 'axes.mat' which provides the xv,
%       yv, zv and t_cmc variables. It may also contain an optional variable
%       zv_precision, which is used to control the precision when doing lookups
%       along the z axis (default: 1e-6).
%       The driving field itself must be saved per z slice, in files called
%       'data_ZI.mat', where ZI gives the z position of the slice as an index
%       of zv, i.e. zv(ZI) is the z position.
%       Each of these files must contain an array driving_field(XI,YI,C,TI),
%       where XI, YI and TI are indices corresponding to the variables xv, yv
%       and t_cmc, respectively, and C is used to specify the electric field
%       component in the case of a polarized driving field.
%       In order to avoid large amounts of data to be loaded into the RAM,
%       there is also a possibility to subdivide the data files. For this, you
%       can use a more general way of indexing the driving_field variable:
%       Instead of driving_field(XI,YI,C,TI), you can use
%       driving_field(DI,C,TI), which is treated equally due to an internal
%       reshape operation. The index DI=(XI-1)+(YI-1)*length(xv)-1 is a
%       flattened version of the indices (XI,YI). Using this indexing, you can
%       arbitrarily subdivide the files along the DI index, i.e. instead of one
%       big file 'data_1.mat' containing the array driving_field(1:100,1,1:500),
%       you can for example provide two files 'data_1.1.mat' and 'data_1.2.mat',
%       containing driving_field(1:30,1,1:500) and driving_field(31:100,1,...
%       1:500), respectively.
%     config.ionization_fraction (optional) -
%       name of a .m file (without the .m) containing a function
%       ionization_fraction(t_cmc,Et,config) that computes the time-dependent
%       ionization fraction from the driving field to be able to account for
%       ground state depletion
%       (note: not using function handle in order to maintain octave
%       compatibility, which does not support isequal on function handles
%       until 3.4)
%     config.static_ionization_rate (optional) -
%       instead of a callback function for the ionization fraction, you can
%       specify the static ionization rate w(E) of the gas particle as an array
%       to account for ground state depletion, in 1/s
%     config.static_ionization_rate_field (optional) -
%       E axis for static_ionization_rate option, in V/m
%     config.ionization_potential - in eV
%     config.tau_interval_length - how far to integrate back in time, in
%                                  driving field periods
%     config.tau_window_length - length of soft window after integration to
%                                reduce noise, in driving field periods
%     config.t_window_length - length of soft window applied to d(t) to reduce
%                              noise, in driving field periods
%     config.periodic (optional) - if 1, the input driving field is assumed to
%                                  be periodic; in this case the time axis must
%                                  be a periodically continuable subdivision of
%                                  the [0,2*pi) interval and
%                                  config.t_window_length must be zero and can
%                                  be omitted
%     config.symmetry (optional) - can be '', 'x', 'y' or 'xy' to indicate
%                                  symmetry of the driving field respective to
%                                  the given axes, or 'rotational' for
%                                  rotational symmetry, which will speed up the
%                                  computation
%     config.omega_ranges (optional) - can be used to keep cache files small
%                                      when you are only interested in certain
%                                      ranges of omega values; the format is
%                                      [start1 end1; start2 end2; ...].
%     config.raw (optional) - if 1, also the part of the spectrum for negative
%                             omegas is returned, so that the time-dependent
%                             dipole response can be easily reconstructed with
%                             an inverse fft
%     config.cache (optional) - a struct that controls the cache. Important values are:
%       config.cache.directory - if set, calculated spectra are saved to disk at the
%                                specified directory.
%       config.cache.fast_directory -
%         if set, this directory is used for operations that need good hard drive
%         performance. You can specify a directory on an SSD or on a local hard drive
%         if config.cache.directory points to a network drive.
%       config.cache.backend - can be set to 'NetCDF' (default) or 'fallback' which is
%                              a method to get an on-disk cache for installations of
%                              Octave without NetCDF support.
%       config.cache.transpose_RAM (optional, default: 1GB) -
%         can be used to control the RAM consumption of a transpose operation necessary
%         to avoid non-linear disk access. If you use larger values, the operation will
%         be faster.
%   config.components (optional) - if using non-linear polarization, this must be set
%                                  to the number of electric field vector components
%   any config fields required by config.driving_field
%     dipole-matrix-element-specific config fields required by hhgmax_lewenstein.cpp
%   progress (optional) - a struct() that contains information about the
%                         progress of the calculation, as returned as third
%                         return value (useful if this function is called
%                         several times); if passed, needs at least a
%                         points_total field
%   return_omega (optional) - can be [start_omega end_omega] or an index
%                             referring to the omega return value; used to
%                             restrict the range of omega values returned
%
% Return values:
%   omega - the angular frequency axis corresponding to the dipole response
%           coefficients
%   response_cmc - an array with size length(yv) x length(xv) x length(zv) x
%                  C x length(omega), containing the dipole response spectrum
%                  at each spatial grid point, where C is the number of
%                  components (1 for linear polarization, 2 for elliptical
%                  polarization)
%   progress (optional) - information about the progress of the computation, as
%                         struct()
%
% Example:
%   see PDF documentation

function [omega, response_cmc, progress] = hhgmax_dipole_response(t_cmc, xv, yv, zv,...
                                                           config, progress,...
                                                           return_omega)

% if using Windows, make accessible DLL files needed for lewenstein module
if ispc()
  [rootpath] = fileparts(mfilename('fullpath'));
  bits = computer('arch'); bits = bits(end-1:end); % 32 or 64

  % use file sizes to find out if we already have DLL files for correct architecture
  if ~exist(fullfile(rootpath,'vcomp90.dll'), 'file')
    current_size = 0;
  else
    fileinfo = dir(fullfile(rootpath,'vcomp90.dll'));
    current_size = fileinfo.bytes;
  end

  % get the size of the correct vcomp90 DLL file
  fileinfo = dir(fullfile(rootpath, ['dll' bits], 'vcomp90.dll'));
  if ~length(fileinfo)
    error('Missing DLL directory.');
  end
  correct_size = fileinfo.bytes;

  % copy files if necessary
  if current_size~=correct_size
    'Copying necessary DLL files'
    copyfile(fullfile(rootpath,['dll' bits], '*'), rootpath);
  end
end

% parse components option
components = 1;
if isfield(config,'components')
  components = config.components;
end

% Octave has still flipdim instead of flip function, which is needed later
if ~exist('flip')
  flip = @flipdim;
end

% prepare driving field
if isfield(config,'precomputed_driving_field')
  % verify axes
  ax_filename = fullfile(config.precomputed_driving_field, 'axes.mat');
  ax = load(ax_filename);
  if ~isequal(xv, ax.xv) || ~isequal(yv, ax.yv) || ~isequal(t_cmc, ax.t_cmc)
    error('axes of precomputed driving field do not match')
  end

  % set zv lookup precision
  if isfield(ax,'zv_precision')
    zv_precision = ax.zv_precision;
  else
    zv_precision = 1e-6; % 1nm
  end

  % initialize data variable
  df_data = [];
  df_DI = 1;
  df_chunk = 0;

  % give a warning when using cache
  if isfield(config,'backend') && ~strcmpi(config.backend,'RAM')
    warning('using precomputed driving field with hard drive cache - make sure to erase cache when you alter the driving field data!');
  end
else
  % create handle for driving field function
  dotpos = strfind(config.driving_field, '.');

  if dotpos
    % replace *.method_name by hhgmax_method_name to avoid problems with Octave
    driving_field = str2func(['hhgmax_' config.driving_field(dotpos+1:end)]);
  else
    driving_field = str2func(config.driving_field);
  end
end

% shift time axis to zero (required for lewenstein and window setup)
t0 = t_cmc(1);
t_cmc = t_cmc - t0;

% needed to compute ground state amplitude
dt = t_cmc(2)-t_cmc(1);

% copy configuration
lewenstein_config = config;

% setup weights for tau integration
tau_interval_pts = length(find(t_cmc<=2*pi*config.tau_interval_length));
tau_window_pts = length(find(t_cmc<2*pi*config.tau_window_length));

weights = ones(1, tau_interval_pts+tau_window_pts);
if tau_window_pts~=1
  tau_window_factor = pi/2 / (tau_window_pts-1);
else % avoid division by zero
  tau_window_factor = 0.5;
end
tau_window = cos(tau_window_factor * (0:tau_window_pts-1) ) .^ 2;
weights(tau_interval_pts+1:tau_interval_pts+tau_window_pts) = weights(tau_interval_pts+1:tau_interval_pts+tau_window_pts) .* tau_window;

lewenstein_config.weights = weights;

% create omega axis and prepare data reduction
deltat = t_cmc(2);
[omega, cache_keep] = hhgmax_get_omega_axis(t_cmc, config);

% apply return_omega
if exist('return_omega','var') && length(return_omega)
  if numel(return_omega)==1
    keep_start = return_omega;
    keep_end = return_omega;
  elseif numel(return_omega)==2
    from = return_omega(1);
    to = return_omega(2);
    keep = find(omega>=from & omega<=to);
    keep_start = keep(1);
    keep_end = keep(end);
  else
    error('Invalid format for return_omega argument.')
  end
else
  keep_start = 1;
  keep_end = length(omega);
end

if isfield(config,'periodic') && config.periodic
  % check t_cmc axis
  if abs(max(t_cmc)+deltat - 2*pi)>1e-15
    error('For periodic mode, time axis must be a periodically continuable subdivision of the [0,2*pi) interval.')
  end

  % make sure t window is disabled
  if isfield(config, 't_window_length') && config.t_window_length ~= 0
    error('For periodic mode, t_window_length must be zero.')
  else
    t_window_length = 0;
  end

  % extend time axis
  repetitions = ceil(config.tau_interval_length+config.tau_window_length+1);
  fft_length = length(t_cmc);
  t_cmc = (0:repetitions*fft_length-1) * deltat;
  % Fourier transformation must only be applied to right block of d_t
  % omega must be the omega for the original t_cmc
else
  fft_length = length(t_cmc);
  repetitions = 1;

  t_window_length = config.t_window_length;

  if length(weights)>length(t_cmc)
    warning('tau_interval_length + tau_window_length is longer than considered time interval')
  end
end

% convert ionization potential from eV to scaled atomic units
lewenstein_config.ip = hhgmax_sau_convert(config.ionization_potential*1.602176565e-19, 'U', 'SAU', config);

% setup window for d(t)
t_window_pts = length(find(t_cmc<2*pi*t_window_length));
if t_window_pts~=1
  t_window_factor = pi/2 / (t_window_pts-1);
else % avoid division by zero
  t_window_factor = 0.5;
end
t_window = cos(t_window_factor * (0:t_window_pts-1) ) .^ 2;

% preallocate memory for return value
data_size = [length(yv),length(xv),length(zv),components,keep_end-keep_start+1];
response_cmc = complex(nan(data_size), nan(data_size));

% parse symmetry option
symmetry_x = 0;
symmetry_y = 0;
symmetry_rotational = 0;
if isfield(config,'symmetry') && length(config.symmetry)
  if strcmpi(config.symmetry,'x')
    symmetry_x = 1;
  elseif strcmpi(config.symmetry,'y')
    symmetry_y = 1;
  elseif strcmpi(config.symmetry,'xy')
    symmetry_x = 1;
    symmetry_y = 1;
  elseif strcmpi(config.symmetry,'rotational')
    symmetry_x = 1;
    symmetry_y = 1;
    symmetry_rotational = 1;
  elseif config.symmetry
    error('config.symmetry must be one of ''x'', ''y'' or ''xy'', ''rotational'' or a false value');
  end
end

% make sure axes conform to symmetry options
if symmetry_x && ( ~length(find(abs(xv)<1e-10)) || ~all(abs(xv+fliplr(xv))<1e-10) )
  error('x axis must be symmetric and contain 0 due to config.symmetry setting');
end

if symmetry_y && ( ~length(find(abs(yv)<1e-10)) || ~all(abs(yv+fliplr(yv))<1e-10) )
  error('y axis must be symmetric and contain 0 due to config.symmetry setting');
end

% initialize cache
metadata = struct();
metadata.omega = omega;
metadata.xv = xv;
metadata.yv = yv;
metadata.config = config;
metadata.symmetry_x = symmetry_x;
metadata.symmetry_y = symmetry_y;
metadata.symmetry_rotational = symmetry_rotational;

if symmetry_x
  cache_xn = (length(xv)-1)/2 + 1;
else
  cache_xn = length(xv);
end

if symmetry_y
  cache_yn = (length(yv)-1)/2 + 1;
else
  cache_yn = length(yv);
end
cache_yi = 1:cache_yn;

if symmetry_rotational
  cache_yn = 1;
  cache_yi = find(abs(yv)==min(abs(yv)), 1, 'first'); % find yv==0 but with tolerance
end

if ~isfield(config,'cache')
  config.cache = struct();
end

d_cache = hhgmax_cache(cache_xn,cache_yn,zv,components,length(omega),config.cache,metadata);
d_cache.open();

% parse ionization rate option
if isfield(config,'static_ionization_rate')
  if isfield(config,'periodic') && config.periodic
    error('You cannot specify ionization rates for periodic mode.');
  end
  if ~isfield(config,'static_ionization_rate_field')
    error('You need to specify a E axis for your ionization rates using the static_ionization_rate_field config option.');
  end

  irate = 1 ./ hhgmax_sau_convert(1./config.static_ionization_rate, 't', 'SAU', config);
  irate_E = hhgmax_sau_convert(config.static_ionization_rate_field,'E','SAU',config);
elseif isfield(config,'ionization_fraction')
  % create handle for driving field function
  dotpos = strfind(config.driving_field, '.');

  if dotpos
    % replace *.method_name by hhgmax_method_name to avoid problems with Octave
    ionization_fraction = str2func(['hhgmax_' config.ionization_fraction(dotpos+1:end)]);
  else
    ionization_fraction = str2func(config.ionization_fraction);
  end
else
  % in this case prepare ground state amplitude already here for performance
  lewenstein_config.ground_state_amplitude = ones(1,length(t_cmc));
end

% initialize progress struct
if ~exist('progress', 'var') || ~length(progress)
  progress = struct();
  progress.points_total = length(xv)*length(yv)*length(zv);
end
if ~isfield(progress, 'points_computed')
  progress.points_computed = 0;
end
if ~isfield(progress, 'time_spent')
  progress.time_spent = 0;
end

if ~isfield(progress, 'points_effective')
  progress.points_effective = progress.points_total;

  if symmetry_x
    progress.points_effective = round(progress.points_effective / length(xv) * cache_xn);
  end
  if symmetry_y
    progress.points_effective = round(progress.points_effective / length(yv) * cache_yn);
  end
end

% start time measurement
% (not using tic/toc because octave can't return a tic handle)
time_start = clock;
last_status = time_start;

for zi=1:length(zv)
  % try to get from HD cache
  from_cache = d_cache.get_slice(zi, keep_start, keep_end);

  if length(from_cache)
%    response_cmc(:,:,zi,1:size(from_cache,4),:) = from_cache;
    response_cmc(cache_yi,1:cache_xn,zi,:,:) = from_cache;
    progress.points_effective = progress.points_effective - round(size(from_cache,1)*size(from_cache,2) * progress.points_effective/progress.points_total);
    continue
  end

  % compute dipole response spectrum from driving field, applying the soft window
  for xi=1:cache_xn
    for yi=cache_yi

      % get driving field
      if exist('driving_field', 'var')
        % from callback function
        Et_cmc = real(driving_field(xv(xi),yv(yi),zv(zi), config));
      else
        % precomputed driving field
        if df_DI>size(df_data,1)
          % lookup in ax.zv
          df_ZI = find(abs(ax.zv-zv(zi))<=zv_precision,1,'first');
          if ~length(df_ZI)
            error(['precomputed data does not contain a slice at z=' num2str(zv(zi)) '; '...
                   'consider increasing the zv_precision variable']);
          end

          % first, try data_ZI.mat, if not exists, try data_ZI.N.mat
          basefilename = ['data_' num2str(df_ZI)];
          df_filename = fullfile(config.precomputed_driving_field, [basefilename '.mat']);
          if ~exist(df_filename, 'file')
            df_chunk = df_chunk+1;
            df_filename = fullfile(config.precomputed_driving_field, [basefilename '.' num2str(df_chunk) '.mat']);
            if ~exists(df_filename, 'file')
              error('no data for precomputed driving field left');
            end
          end
          df_struct = load(df_filename);
          df_data = df_struct.driving_field;
          components = size(df_data, ndims(df_data)-1);
          t_length = size(df_data, ndims(df_data));
          df_data = reshape(df_data, [numel(df_data)/components/t_length components t_length]);

          df_DI = 1;
        end

        Et_cmc = reshape(df_data(df_DI,:,:), [size(df_data,2) size(df_data,3)]);
        df_DI = df_DI+1;
      end

      % prepare driving field (for case of periodic mode)
      Et_cmc = repmat(Et_cmc, 1, repetitions);

      % compute time-dependent ground state amplitude if callback specified
      if isfield(config,'ionization_fraction')
        ifrac = ionization_fraction(t_cmc,Et_cmc,config);
        lewenstein_config.ground_state_amplitude = sqrt(1 - ifrac);
      end

      % compute time-dependent ground state amplitude if static ionization rates specified
      if isfield(config,'static_ionization_rate')
        Eabs = sqrt(sum(real(Et_cmc).^2,1)); % |\vec E_cmc|
        w = interp1(irate_E, irate, Eabs);

        % To compute ground state amplitude |a(t)|, use
        %   P(Ionization) = 1 - |a(t)|^2 => |a(t)| = sqrt(1 - P(Ionization))
        % together with (6) from Tong, Lin (2005):
        %   P(Ionization) = 1 - exp( - \int w(t) dt )
        % but do not integrate until infinity.
        % Note: (4) of Cao et al. (2006) is wrong, it should be |a(t)|^2 so here
        %       we use sqrt
        lewenstein_config.ground_state_amplitude = sqrt(exp(-cumtrapz(t_cmc,w)));
      end

      % compute dipole response
      d_t = hhgmax_lewenstein(t_cmc, Et_cmc, lewenstein_config);
      d_t = d_t(:,length(d_t)-fft_length+1:length(d_t));
      if size(d_t,1)~=components
        error(['Got more/less components than expected from dipole response module. '...
              'Probably the driving field is non-linearly polarized, so you need to set config.components to 2 or 3 as appropriate.'])
      end

      % apply soft window
      win_start = length(t_cmc)-t_window_pts+1;
      win_end = length(t_cmc);
      d_t(:,win_start:win_end) = d_t(:,win_start:win_end) .* repmat(t_window,components,1);

      % compute spectrum
      d_omega = conj(fft(d_t, [], 2));

      % discard irrelevant part of spectrum
      d_omega = d_omega(:,cache_keep);

      % Integration of fft starts at 0, we want to start at
      % t0, therefore apply following exponential term.
      % Furthermore, multiply by deltat to get units right.
      d_omega = d_omega .* repmat(exp(-i*omega*t0),components,1) * deltat;

      % save relevant part of spectrum
      d_cache.set_point(xi,yi-cache_yi(1)+1,zi,d_omega);

      % status information
      progress.points_computed = progress.points_computed + 1;

      time_now = clock;
      time_diff = etime(time_now,time_start);
      if etime(time_now,last_status) >= 1 % not more often than every second
        percent = 100 * progress.points_computed /  progress.points_effective;

        time_spent = progress.time_spent + time_diff;
        time_total = time_spent / progress.points_computed * progress.points_effective;
        time_left = time_total - time_spent;

        time_spent_s = num2str(mod(floor(time_spent), 60), '%02u');
        time_spent_min = num2str(mod(floor(time_spent/60), 60), '%02u');
        time_spent_h = num2str(floor((time_spent)/3600), '%02u');

        time_total_s = num2str(mod(floor(time_total), 60), '%02u');
        time_total_min = num2str(mod(floor(time_total/60), 60), '%02u');
        time_total_h = num2str(floor((time_total)/3600), '%02u');

        time_left_s = num2str(mod(floor(time_left), 60), '%02u');
        time_left_min = num2str(mod(floor(time_left/60), 60), '%02u');
        time_left_h = num2str(floor((time_left)/3600), '%02u');

        disp(['dipole_response: computed point ' num2str(progress.points_computed)...
         ' of ' num2str(progress.points_effective, '%02u') ' (' num2str(round(percent))...
         '%). Time spent: ' time_spent_h ':' time_spent_min ':' time_spent_s...
         '; Time left: ' time_left_h ':' time_left_min ':' time_left_s...
         ' of ' time_total_h ':' time_total_min ':' time_total_s ' (roughly). '...
         'Computing at ' num2str(progress.points_computed/time_spent)...
         ' points per second.']);

        last_status = time_now;
      end
    end
  end

  % mark slice as complete;
  % save or process data
  d_cache.finish_slice(zi);

  % get the whole slice
%  response_cmc(:,:,zi,:,:) = d_cache.get_slice(zi, keep_start, keep_end);
  response_cmc(cache_yi,1:cache_xn,zi,:,:) = d_cache.get_slice(zi, keep_start, keep_end);
end

d_cache.close();

'extend data according to symmetry'
if symmetry_rotational
  % prepare interpolation - d(r) is given by dr and rv, query grid is rq
  rv = flip(-xv(1:cache_xn), 2);
  dr = reshape(response_cmc(cache_yi,1:cache_xn,:,:,:), [cache_xn length(zv) components keep_end-keep_start+1]);
  dr = flip(dr, 1);
  clear response_cmc;

  [x_mesh y_mesh] = meshgrid(xv,yv);
  rq = sqrt(x_mesh.^2 + y_mesh.^2);

  % interpolate
  for xi=1:length(xv)
    response_cmc(:,xi,:,:,:) = interp1(rv, dr, rq(:,xi), [], 0);
  end

  % free some RAM
  clear rv dr x_mesh y_mesh rq;
end

if symmetry_y && ~symmetry_rotational
  tic
  response_cmc(cache_yn+1:end,:,:,:,:) = flip(response_cmc(1:cache_yn-1,:,:,:,:), 1);
  toc
end
if symmetry_x && ~symmetry_rotational
  tic
  response_cmc(:,cache_xn+1:end,:,:,:) = flip(response_cmc(:,1:cache_xn-1,:,:,:), 2);
  toc
end
'extend data according to symmetry done'

progress.time_spent = progress.time_spent + etime(clock, time_start);

omega = omega(keep_start:keep_end);
