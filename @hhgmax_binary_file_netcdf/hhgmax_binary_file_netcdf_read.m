function data = hhgmax_binary_file_netcdf_read(instance, variable, start, count)

if ~exist('+netcdf/create','file')
  % necessary for Octave + netcdf package to be able to use dot syntax
  import_netcdf
end

ncid = netcdf.open(instance.filename,'NOWRITE');
varid = netcdf.inqVarID(ncid,variable);

data = netcdf.getVar(ncid,varid,start-ones(size(start)),count);

netcdf.close(ncid);
