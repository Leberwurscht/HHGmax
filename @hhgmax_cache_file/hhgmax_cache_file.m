function instance = hhgmax_cache_file(xn,yn,zv,components,omegan,config,metadata)

% check if cache directory is set
if ~isfield(config, 'directory')
  error('cache needs directory option set');
end

% metadata filename
filename = fullfile(config.directory, 'metadata.mat');

% make sure by checking the metadata file that we don't access an inapproriate
% directory
if exist(config.directory, 'file')
  % make sure we have a valid directory
  if ~isdir(config.directory)
    error('directory option is set to a non-directory');
  end

  % error for non-empty directory without metadata file
  directory_empty = ( length(dir(config.directory)) == 2 );
  if ~directory_empty && ~exist(filename, 'file')
    error('specified cache directory contains files but no metadata file!');
  end

  % check if saved metadata fits
  if ( ~isfield(config,'check_metadata') || config.check_metadata )...
     && exist(filename, 'file')

    loaded_metadata = load(filename);
    if ~isequal(loaded_metadata,metadata)
      answer = input(['cache directory contains inappropriate data. '...
                     'Do you want to delete it? (y/n)'],'s');

      if strcmpi(answer, 'y')
        delete(fullfile(config.directory, '*'));
      else
        error('Aborted due to inappropriate data in cache directory.');
      end
    end
  end
end

% create directory if it does not exist
if ~exist(config.directory, 'file')
  mkdir(config.directory);
end

% create metadata file if it does not exist
if ~exist(filename, 'file')
  save(filename,'-mat','-struct', 'metadata');
end

% create fast cache directory and empty it
if isfield(config, 'fast_directory')
  % make sure we have a valid directory
  if exist(config.fast_directory, 'file') && ~isdir(config.fast_directory)
    error('fast_directory option is set to a non-directory');
  end

  % error for non-empty directory without a fast_cache.mat file
  % (just to prevent writing in inappropriate directories)
  fast_filename = fullfile(config.fast_directory, 'fast_cache.mat');
  if length(dir(config.fast_directory))>2 && ~exist(fast_filename,'file')
    error('specified fast cache directory contains files but no fast_cache.mat file!');
  end

  % create directory if it does not exist
  if ~exist(config.fast_directory, 'file')
    mkdir(config.fast_directory);
  end

  % create fast_cache.mat file if it does not exist
  if ~exist(fast_filename, 'file')
    s = struct();
    save(fast_filename,'-mat','-struct', 's');
  end
end

% set directories
instance.directory = config.directory;
if isfield(config, 'fast_directory')
  instance.fast_directory = config.fast_directory;
else
  instance.fast_directory = config.directory;
end

% binary file structure
instance.structure = struct();
instance.structure.dimensions.x = xn;
instance.structure.dimensions.y = yn;
instance.structure.dimensions.component = components;
instance.structure.dimensions.omega = omegan;
instance.structure.variables.E_real = {'component','omega','y','x'};
instance.structure.variables.E_imag = {'component','omega','y','x'};

instance.structure.dimensions.finished = 1;
instance.structure.variables.finished = {'finished'};

% save z axis
instance.zv = zv;

% chose backend
instance.backend = @hhgmax_binary_file_netcdf; % default
instance.extension = '.nc';
if isfield(config, 'backend')
  if strcmpi(config.backend, 'fallback')
    instance.backend = @hhgmax_binary_file_fallback;
    instance.extension = '.dat';
  elseif ~strcmpi(config.backend, 'NetCDF')
    error('invalid file cache backend');
  end
end

% prepare transpose step in finish_slice - structure of transposed file
instance.structure_t = instance.structure;
instance.structure_t.variables.E_real = {'y','x','component','omega'};
instance.structure_t.variables.E_imag = {'y','x','component','omega'};

% prepare transpose step in finish_slice - available RAM
if isfield(config, 'transpose_RAM')
  instance.transpose_RAM = config.transpose_RAM * 1000000000; % GB
else
  instance.transpose_RAM = 1000000000;
end

RAM_per_frequency = components*xn*yn * 8 * 2;
  % 8 = size of double, *2 because permute is not in-place

instance.transpose_chunksize = round(instance.transpose_RAM/RAM_per_frequency);

% convert struct to class
instance = class(instance, 'hhgmax_cache_file');
