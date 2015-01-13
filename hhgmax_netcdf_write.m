function netcdf_write(filename,varname,data,start)

if exist('+netcdf/create','file') || exist('netcdf_create')
  % for Matlab or Octave + netcdf package

  if ~exist('+netcdf/create','file')
    % necessary for Octave + netcdf package to be able to use dot syntax
    import_netcdf
  end

  ncid = netcdf.open(filename,'WRITE');
  varid = netcdf.inqVarID(ncid,varname);

  [tmp,tmp,dimids,tmp] = netcdf.inqVar(ncid,varid);
  ndims = length(dimids);
  datasize = size(data);
  datasize(end+1:ndims) = 1;
  datasize = datasize(1:ndims);
  if ~exist('start','var')
    start = ones([1 ndims]);
  end

  netcdf.putVar(ncid,varid,start-ones(size(start)),datasize,data);
  netcdf.close(ncid);

elseif exist('ncdouble')

  ncwrite(filename,varname,data,start);

else
  error('Your version of Matlab/Octave does not support NetCDF');
end
