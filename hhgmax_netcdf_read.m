function ret = netcdf_read(filename,varname,start,count)

if exist('+netcdf/create','file') || exist('netcdf_create')
  % for Matlab or Octave + netcdf package

  if ~exist('+netcdf/create','file')
    % necessary for Octave + netcdf package to be able to use dot syntax
    import_netcdf
  end

  ncid = netcdf.open(filename,'NOWRITE');
  varid = netcdf.inqVarID(ncid,varname);

  if ~exist('start','var') && ~exist('count','var')
    ret = netcdf.getVar(ncid,varid);
  elseif ~exist('count','var')
    ret = netcdf.getVar(ncid,varid,start-ones(size(start)));
  else
    ret = netcdf.getVar(ncid,varid,start-ones(size(start)),count);
  end

  netcdf.close(ncid);

elseif exist('ncdouble')

  ret = ncread(filename,varname,start,count);

else
  error('Your version of Matlab/Octave does not support NetCDF');
end
