% save z slice to disk
function cache_finish_slice(cache, zi)
'cache_finish_slice'

if strcmpi(cache.mode, 'NetCDF')
  % NetCDF mode

  if isfield(cache.config, 'netcdf_fast_cachedir')
    fast_cache_dir = cache.config.netcdf_fast_cachedir;
  else
    fast_cache_dir = cache.config.cachedir;
  end

  % set finished flag
  filename = fullfile(fast_cache_dir, ['dipole_response_z' num2str(cache.zv(zi)) '.nc']);
  netcdf_write(filename, 'finished' , 1);

  % transpose if transpose option is set
  if isfield(cache.config, 'netcdf_transpose') && cache.config.netcdf_transpose
    filename_t = fullfile(fast_cache_dir, ['dipole_response_z' num2str(cache.zv(zi)) '_transposed.nc']);
    cache_create_netcdf(cache, filename_t, 1);

    % parse memory option which makes it possible to control RAM usage
    if isfield(cache.config, 'netcdf_transpose_memory')
      RAM_available = cache.config.netcdf_transpose_memory * 1000000000;
    else
      RAM_available = 1000000000;
    end

    RAM_per_frequency = cache.components*cache.points_x*cache.points_y * 8 * 2;
      % 8 = size of double, *2 because permute is not in-place

    chunksize = round(RAM_available/RAM_per_frequency);

    % copy over to new file in small frequency chunks
    for omega_i_start=1:chunksize:length(cache.omega)
      'transpose'
      omega_i_end = min(omega_i_start+chunksize-1, length(cache.omega));
      [omega_i_start omega_i_end]

      tic
      from_cache_real = permute(netcdf_read(filename, 'E_real', [1 omega_i_start 1 1],...
        [cache.components omega_i_end-omega_i_start+1 cache.points_y cache.points_x]), [3 4 1 2]);
      netcdf_write(filename_t, 'E_real', from_cache_real, [1 1 1 omega_i_start]);
      clear from_cache_real;
      toc

      tic
      from_cache_imag = permute(netcdf_read(filename, 'E_imag', [1 omega_i_start 1 1],...
        [cache.components omega_i_end-omega_i_start+1 cache.points_y cache.points_x]), [3 4 1 2]);
      netcdf_write(filename_t, 'E_imag', from_cache_imag, [1 1 1 omega_i_start]);
      clear from_cache_imag;
      toc
    end

    netcdf_write(filename_t, 'finished' , 1);
    delete(filename);
  end

  % move from fast cache to mass storage
  if isfield(cache.config, 'netcdf_fast_cachedir')
    if exist(filename_t,'file')
      source = filename_t;
      destination = fullfile(cache.config.cachedir, ['dipole_response_z' num2str(cache.zv(zi)) '_transposed.nc']);
    else
      source = filename;
      destination = fullfile(cache.config.cachedir, ['dipole_response_z' num2str(cache.zv(zi)) '.nc']);
    end

    'move to mass storage'
    tic
    movefile(source, destination);
    toc
    'move to mass storage done'
  end

else
  % compatible mode

  % mark as finished in-memory
  cache.finished(zi) = 1;

  % write to disk if cachedir is set
  if isfield(cache.config,'cachedir')
    s = struct();
    s.dipole_response = cache.data(:,:,zi,:,:);

    filename = fullfile(cache.config.cachedir, ['dipole_response_z' num2str(cache.zv(zi)) '.mat']);
    save(filename,'-mat','-struct', 's');
  end

end

'cache_finish_slice done'
