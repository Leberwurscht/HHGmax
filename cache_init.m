function cache = cache_init(xv, yv, zv, components, omega, config)
'cache_init'
tic

cache = struct();
cache.xv = xv;
cache.yv = yv;
cache.zv = zv;
cache.components = components;
cache.omega = omega;
cache.config = config;

% parse symmetry option
cache.symmetry_x = 0;
cache.symmetry_y = 0;
if isfield(config,'symmetry') && length(config.symmetry)
  if strcmpi(config.symmetry,'x')
    cache.symmetry_x = 1;
  elseif strcmpi(config.symmetry,'y')
    cache.symmetry_y = 1;
  elseif strcmpi(config.symmetry,'xy')
    cache.symmetry_x = 1;
    cache.symmetry_y = 1;
  elseif config.symmetry && ~strcmpi(config.symmetry,'rotational')
    error('config.symmetry must be one of ''x'', ''y'' or ''xy'', ''rotational'' or a false value');
  end
end

% make sure axes conform to symmetry options
if cache.symmetry_x && ( ~length(find(xv==0)) || ~all(abs(xv+fliplr(xv))<1e-10) )
  error('x axis must be symmetric and contain 0 due to config.symmetry setting');
end

if cache.symmetry_y && ( ~length(find(yv==0)) || ~all(abs(yv+fliplr(yv))<1e-10) )
  error('y axis must be symmetric and contain 0 due to config.symmetry setting');
end

% set cache.points_x and cache.points_y
if cache.symmetry_x
  cache.points_x = (length(xv)-1)/2 + 1;
else
  cache.points_x = length(xv);
end

if cache.symmetry_y
  cache.points_y = (length(yv)-1)/2 + 1;
else
  cache.points_y = length(yv);
end

% parse NetCDF option
if ~isfield(config,'use_netcdf_cache') || ~config.use_netcdf_cache
  % Compatible mode: in-memory cache
  cache.mode = 'Compatible';

  data_size = [cache.points_y,cache.points_x,length(zv),components,length(omega)];
  cache.data = complex(nan(data_size), nan(data_size));
  cache.finished = zeros([1 length(zv)]); % for marking z slices as finished
else
  % NetCDF cache: dipole responses are written to hard disk immediately
  cache.mode = 'NetCDF';

  % make sure this is Matlab, or Octave with a suitable package installed
  if ~exist('+netcdf/create','file') && ~exist('netcdf_create') && ~exist('ncdouble')
    error(['No function for creating netcdf files available. For Octave, '...
          'install octave-octcdf or octave-netcdf package, or unset '...
          'config.use_netcdf_cache.']);
  end

  % make sure cache directory is given
  if ~isfield(config,'cachedir')
    error('need config.cachedir if use_netcdf_cache is set.');
  end
end

% prepare cache directory if used
if isfield(config,'cachedir')
  filename = fullfile(cache.config.cachedir, 'metadata.mat');

  % check metadata file and abort or delete directory if inappropriate
  if exist(cache.config.cachedir, 'dir')
    if exist(filename, 'file')
      cached = load(filename);
    end

    if (~exist('cached','var') || ~isequal(cached.omega, cache.omega) || ~isequal(cached.xv, cache.xv) || ~isequal(cached.yv, cache.yv) || ~isequal(cached.config, cache.config) || ~isequal(cached.symmetry_x, cache.symmetry_x) || ~isequal(cached.symmetry_y, cache.symmetry_y)) && length(dir(cache.config.cachedir))>2 && ~(isfield(cache.config,'omit_cache_check') && cache.config.omit_cache_check)
      answer = input('config.cachedir contains inappropriate data. Do you want to delete it? (y/n)','s');
      if strcmpi(answer, 'y')
        delete(fullfile(cache.config.cachedir, '*'));
      else
        error('Aborted due to inappropriate data in cache.');
      end
    end
  end

  % create directory if it does not exist
  if ~exist(cache.config.cachedir, 'dir')
    mkdir(cache.config.cachedir);
  end

  % create fast cachedir and empty it
  if isfield(cache.config, 'netcdf_fast_cachedir')
    if ~exist(cache.config.netcdf_fast_cachedir, 'dir')
      mkdir(cache.config.netcdf_fast_cachedir);
    end

    if length(dir(cache.config.netcdf_fast_cachedir))>2
      delete(fullfile(cache.config.netcdf_fast_cachedir, '*'));
    end
  end

  % create metadata file if it does not exist
  if ~exist(filename, 'file')
    s = struct();
    s.omega = cache.omega;
    s.xv = cache.xv;
    s.yv = cache.yv;
    s.config = cache.config;
    s.symmetry_x = cache.symmetry_x;
    s.symmetry_y = cache.symmetry_y;
    save(filename,'-mat','-struct', 's');
  end
end

toc
'cache_init done'
