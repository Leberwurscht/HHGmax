% set dipole response on a point of the space grid

% expects the following variables:
%   cache xi yi zi d_omega

% writes to the following variables:
%   cache

% This is NOT a function but a script file, because there is no way to modify function
% arguments in-place from a function that is compatible with both Matlab and Octave.
% (Octave: optimize_subsasgn_calls, Matlab: same name for argument and return value,
% handle classes. optimize_subsasgn_calls and same name should be compatible, but none
% of these methods worked with the versions used by me: Matlab R2012a/Octave 3.6.4)

% To avoid pollution of dipole_response's namespace, all variables that should be
% kept local to this script are set as a property of the cache_set_point struct
% which is cleared later.

'cache_set_point'
tic

% for symmetry, map indices accordingly
cache_set_point_m = struct();

if cache.symmetry_x && xi>(length(cache.xv)-1)/2+1
  cache_set_point_m.map_xi = length(cache.xv)-xi+1;
else
  cache_set_point_m.map_xi = xi;
end
if cache.symmetry_y && yi>(length(cache.yv)-1)/2+1
  cache_set_point_m.map_yi = length(cache.yv)-yi+1;
else
  cache_set_point_m.map_yi = yi;
end

if strcmpi(cache.mode, 'NetCDF')
  % NetCDF mode

  % create NetCDF file if it does not exist
  if isfield(cache.config, 'netcdf_fast_cachedir')
    cache_set_point_m.fast_cache_dir = cache.config.netcdf_fast_cachedir;
  else
    cache_set_point_m.fast_cache_dir = cache.config.cachedir;
  end

  cache_set_point_m.filename = fullfile(cache_set_point_m.fast_cache_dir, ['dipole_response_z' num2str(cache.zv(zi)) '.nc']);
  cache_create_netcdf(cache, cache_set_point_m.filename);

  % write to NetCDF file
%  if isfield(cache.config, 'netcdf_cache_transpose') && cache.config.netcdf_cache_transpose
  netcdf_write(cache_set_point_m.filename, 'E_real',...
    reshape(real(d_omega), [cache.components length(cache.omega) 1 1]),...
    [1 1 cache_set_point_m.map_yi cache_set_point_m.map_xi]...
  );
  netcdf_write(cache_set_point_m.filename, 'E_imag',...
    reshape(imag(d_omega), [cache.components length(cache.omega) 1 1]),...
    [1 1 cache_set_point_m.map_yi cache_set_point_m.map_xi]...
  );
%  else
%    ncwrite(cache_set_point.filename, 'E_real', reshape(real(d_omega),[1 1 cache.components length(cache.omega)]), [cache_set_point.map_xi cache_set_point.map_yi 1 1]);
%    ncwrite(cache_set_point.filename, 'E_imag', reshape(imag(d_omega),[1 1 cache.components length(cache.omega)]), [cache_set_point.map_xi cache_set_point.map_yi 1 1]);
%  end

else
  % compatible mode

  cache.data(cache_set_point_m.map_yi,cache_set_point_m.map_xi,zi,:,:) = d_omega;

end

clear cache_set_point_m;

toc
'cache_set_point done'
