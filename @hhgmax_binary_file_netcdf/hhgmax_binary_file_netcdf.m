function instance = hhgmax_binary_file_netcdf(filename, structure)

% check for support
if ~exist('+netcdf/create','file') && ~exist('netcdf_create')
  error(['Your version of Matlab / Octave does not support NetCDF, for '...
         'Octave you can try to install octave-netcdf.']);
end

% if dimensions are missing in structure, read them from file
if ~exist('+netcdf/create','file')
  % necessary for Octave + netcdf package to be able to use dot syntax
  import_netcdf
end
if any(isnan(cell2mat(struct2cell(structure.dimensions))))
  ncid = netcdf.open(filename,'NOWRITE');
  dim_names = fieldnames(structure.dimensions);

  for dim_i=1:length(dim_names)
    dimid = netcdf.inqDimID(ncid, dim_names{dim_i});
    [dimname, dimlen] = netcdf.inqDim(ncid, dimid);
    structure.dimensions.(dim_names{dim_i}) = dimlen;
  end

  netcdf.close(ncid);
end

% set filename and structure on instance
instance.filename = filename;
instance.structure = structure;

instance = class(instance, 'hhgmax_binary_file_netcdf');
