% create NetCDF file if it does not exist
function cache_create_netcdf(cache, filename, transpose)

% NetCDF file
if exist(filename, 'file')
  return
end

if exist('+netcdf/create','file') || exist('netcdf_create')
  % for Matlab or Octave + netcdf package

  if ~exist('+netcdf/create','file')
    % necessary for Octave + netcdf package to be able to use dot syntax
    import_netcdf
  end

  % use 64BIT_OFFSET to allow more than 2GB, also in MATLAB R2010a
  ncid = netcdf.create(filename, '64BIT_OFFSET');

  ydim = netcdf.defDim(ncid, 'y', cache.points_y);
  xdim = netcdf.defDim(ncid, 'x', cache.points_x);
  componentsdim = netcdf.defDim(ncid, 'component', cache.components);
  omegadim = netcdf.defDim(ncid, 'omega', length(cache.omega));

  if exist('transpose','var') && transpose
    netcdf.defVar(ncid, 'E_real', 'NC_DOUBLE', [ydim,xdim,componentsdim,omegadim]);
    netcdf.defVar(ncid, 'E_imag', 'NC_DOUBLE', [ydim,xdim,componentsdim,omegadim]);

%    nccreate(filename, 'E_real', 'Format', 'classic', 'Dimensions', {'y' cache.points_y 'x' cache.points_x 'component' cache.components 'omega' length(cache.omega)});
%    nccreate(filename, 'E_imag', 'Dimensions', {'y' 'x' 'component' 'omega'});
  else
    netcdf.defVar(ncid, 'E_real', 'NC_DOUBLE', [componentsdim,omegadim,ydim,xdim]);
    netcdf.defVar(ncid, 'E_imag', 'NC_DOUBLE', [componentsdim,omegadim,ydim,xdim]);
%    nccreate(filename, 'E_real', 'Format', 'classic', 'Dimensions', {'component' cache.components 'omega' length(cache.omega) 'y' cache.points_y 'x' cache.points_x});
%    nccreate(filename, 'E_imag', 'Dimensions', { 'component' 'omega' 'y' 'x'});
  end
  finisheddim = netcdf.defDim(ncid, 'finished', 1);
  finishedvar = netcdf.defVar(ncid, 'finished', 'NC_DOUBLE', finisheddim);
  netcdf.endDef(ncid);
  netcdf.putVar(ncid, finishedvar, 1);
  netcdf.close(ncid);

elseif exist('ncdouble')
  % for Octave + octcdf package

  nc = netcdf(filename ,'c');
  nc('x') = cache.points_x;
  nc('y') = cache.points_y;
  nc('component') = cache.components;
  nc('omega') = length(cache.omega);
  if exist('transpose','var') && transpose
    nc{'E_real'} = ncdouble('omega','component','x','y');
    nc{'E_imag'} = ncdouble('omega','component','x','y');
  else
    nc{'E_real'} = ncdouble('x','y','omega','component');
    nc{'E_imag'} = ncdouble('x','y','omega','component');
  end
  nc('finished') = 1;
  nc{'finished'} = ncdouble('finished');
  nc{'finished'}(:) = 0;
  ncclose(nc);

end
