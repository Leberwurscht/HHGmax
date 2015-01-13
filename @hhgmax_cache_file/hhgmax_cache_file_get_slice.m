function slice_data = hhgmax_cache_file_get_slice(instance, zi, query_start, query_end)

% preallocate memory for result
dims = instance.structure.dimensions;
data_size = [dims.y,dims.x,dims.component,query_end-query_start+1];
slice_data = complex(nan(data_size), nan(data_size));

% open file
filename_t = fullfile(instance.directory, ['dipole_response_z' num2str(instance.zv(zi)) '_transposed' instance.extension]);
f_t = instance.backend(filename_t, instance.structure_t);

% check if data available
if ~exist(filename_t, 'file') || ~f_t.read('finished', 1, 1)
  slice_data = [];
  return
end

% read data
from_cache_real = f_t.read('E_real', [1 1 1 query_start], data_size);
from_cache_imag = f_t.read('E_imag', [1 1 1 query_start], data_size);
slice_data = complex(from_cache_real, from_cache_imag);
