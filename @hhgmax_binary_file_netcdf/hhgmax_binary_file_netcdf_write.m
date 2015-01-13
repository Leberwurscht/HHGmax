function data = hhgmax_binary_file_netcdf_write(instance, variable, start, data)

if ~exist('+netcdf/create','file')
  % necessary for Octave + netcdf package to be able to use dot syntax
  import_netcdf
end

ncid = netcdf.open(instance.filename,'WRITE');
varid = netcdf.inqVarID(ncid,variable);

[tmp,tmp,dimids,tmp] = netcdf.inqVar(ncid,varid);
ndims1 = length(dimids);

ndims = length( instance.structure.variables.(variable) );
assert(ndims1==ndims)

if ndims==1
  datasize = length(data);
else
  datasize = size(data);
end
datasize(end+1:ndims) = 1;
datasize = datasize(1:ndims);

netcdf.putVar(ncid,varid,start-ones(size(start)),datasize,data);
netcdf.close(ncid);
