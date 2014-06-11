% try to get a finished z slice from cache
function from_cache = cache_get_slice(cache, zi, keep_start, keep_end)
'cache_get_slice'

% preallocate memory for result
tic
data_size = [length(cache.yv),length(cache.xv),cache.components,keep_end-keep_start+1];
from_cache = complex(nan(data_size), nan(data_size));
'preallocated memory:'
toc

if strcmpi(cache.mode, 'NetCDF')
  % NetCDF mode:

  filename = fullfile(cache.config.cachedir, ['dipole_response_z' num2str(cache.zv(zi)) '.nc']);
  filename_t = fullfile(cache.config.cachedir, ['dipole_response_z' num2str(cache.zv(zi)) '_transposed.nc']);

  if exist(filename_t, 'file') && netcdf_read(filename_t, 'finished')
    % first try to read from transposed file for better performance
    'read transposed file'
    tic
    from_cache_real = netcdf_read(filename_t, 'E_real', [1 1 1 keep_start], [cache.points_y cache.points_x cache.components keep_end-keep_start+1]);
    toc
    tic
    from_cache_imag = netcdf_read(filename_t, 'E_imag', [1 1 1 keep_start], [cache.points_y cache.points_x cache.components keep_end-keep_start+1]);
    toc

    tic
    from_cache(1:cache.points_y,1:cache.points_x,:,:) = complex(from_cache_real, from_cache_imag);
    toc
    tic
    clear from_cache_real, from_cache_imag;
    toc
    'read transposed file done'

  elseif exist(filename, 'file') && netcdf_read(filename, 'finished')
    % then from original file
    'read original file'
    tic
    from_cache_real = permute(netcdf_read(filename, 'E_real', [1 keep_start 1 1], [cache.components keep_end-keep_start+1 cache.points_y cache.points_x]), [3 4 1 2]);
    toc

    tic
    from_cache_imag = permute(netcdf_read(filename, 'E_imag', [1 keep_start 1 1], [cache.components keep_end-keep_start+1 cache.points_y cache.points_x]), [3 4 1 2]);
    toc

    tic
    from_cache(1:cache.points_y,1:cache.points_x,:,:) = complex(from_cache_real, from_cache_imag);
    toc
    tic
    clear from_cache_real, from_cache_imag;
    toc
    'read original file done'

  else
    % then give up
    from_cache = [];
    return;
  end

else
  % Compatible mode:

  filename = fullfile(cache.config.cachedir, ['dipole_response_z' num2str(cache.zv(zi)) '.mat']);

  if cache.finished(zi)
    % first try from memory
    from_cache(1:cache.points_y,1:cache.points_x,:,:) = cache.data(:,:,zi,:,keep_start:keep_end);
  elseif exist(filename, 'file')
    % then from disk
    cached = load(filename);
    from_cache(1:cache.points_y,1:cache.points_x,:,:) = cached.dipole_response(:,:,zi,:,keep_start:keep_end);
  else
    % then give up
    from_cache = [];
    return;
  end

end

% set rest of array if cache contains only a part due to symmetry
if ~exist('flip')
  % Octave has still flipdim instead of flip function
  flip = @flipdim;
end

'flip'
if cache.symmetry_y
  tic
  from_cache(cache.points_y+1:end,:,:,:) = flip(from_cache(1:cache.points_y-1,:,:,:), 1);
  toc
end
if cache.symmetry_x
  tic
  from_cache(:,cache.points_x+1:end,:,:) = flip(from_cache(:,1:cache.points_x-1,:,:), 2);
  toc
end
'flip done'

% % try to get from cache
% if isfield(cache.config,'cachedir')
%   if isfield(cache.config,'use_netcdf_cache') && cache.config.use_netcdf_cache
%     [from_cache, finished] = cache_get(cache, zi, keep);
%     if ~finished
%       from_cache = [];
%     end
%   else
%     if ~exist(cache.config.cachedir,'dir')
%       mkdir(cache.config.cachedir)
%     end
% 
%     filename = fullfile(cache.config.cachedir, ['dipole_response_z' num2str(cache.zv(zi)) '.mat']);
%     if exist(filename, 'file')
%       cached = load(filename);
% 
%       if (isfield(cache.config,'omit_cache_check') && cache.config.omit_cache_check) || (isequal(cached.omega, cache.omega) && isequal(cached.xv, cache.xv) && isequal(cached.yv, cache.yv) && isequal(cached.config, cache.config))
%         from_cache = cached.dipole_response(:,:,:,:,keep);
%   %      response_cmc(:,:,zi,1:size(cached.dipole_response,4),:) = cached.dipole_response;
%   %      progress.points_effective = progress.points_effective - round(size(cached.dipole_response,1)*size(cached.dipole_response,2) * progress.points_effective/progress.points_total);
%   %      continue
%       end
%     end
%   end
% end

'cache_get_slice done'
