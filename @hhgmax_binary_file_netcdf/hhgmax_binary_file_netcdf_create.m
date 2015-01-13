function ret = hhgmax_binary_file_netcdf_create(instance)

dimensions = fieldnames(instance.structure.dimensions);
variables = fieldnames(instance.structure.variables);

if ~exist('+netcdf/create','file')
  % necessary for Octave + netcdf package to be able to use dot syntax
  import_netcdf
end

% open file using 64BIT_OFFSET to allow more than 2GB also in MATLAB R2010a
ncid = netcdf.create(instance.filename, '64BIT_OFFSET');

% create dimensions
dimids = struct();
for ii=1:length(dimensions)
  name = dimensions{ii};
  dimlength = instance.structure.dimensions.(name);
  dimids.(name) = netcdf.defDim(ncid, name, dimlength);
end

% create variables
for ii=1:length(variables)
  name = variables{ii};
  vardims = instance.structure.variables.(name);
  vardimids = [];
  for jj=1:length(vardims)
    vardimids(jj) = dimids.(vardims{jj});
  end
  netcdf.defVar(ncid, name, 'NC_DOUBLE', vardimids);
end

% close file
netcdf.close(ncid);

ret = [];
