function ret = hhgmax_cache_file_finish_slice(instance, zi)

% create file handle
filename = fullfile(instance.fast_directory, ['dipole_response_z' num2str(instance.zv(zi)) instance.extension]);
f = instance.backend(filename, instance.structure);

% set finished flag
f.write('finished', 1, 1);

% create file handle for transposed file
filename_t = fullfile(instance.fast_directory, ['dipole_response_z' num2str(instance.zv(zi)) '_transposed' instance.extension]);
f_t = instance.backend(filename_t, instance.structure_t);

% create transposed file
f_t.create()

% transpose: copy over to new file in small frequency chunks
dims = instance.structure.dimensions;
for omega_i_start=1:instance.transpose_chunksize:dims.omega
  'transpose'
  omega_i_end = min(omega_i_start+instance.transpose_chunksize-1, dims.omega);
  [omega_i_start omega_i_end]

  tic
  from_cache_real = f.read('E_real', [1 omega_i_start 1 1],...
    [dims.component omega_i_end-omega_i_start+1 dims.y dims.x]);
  from_cache_real_t = permute(from_cache_real, [3 4 1 2]);
  clear from_cache_real;
  f_t.write('E_real', [1 1 1 omega_i_start], from_cache_real_t);
  clear from_cache_real_t;
  toc

  tic
  from_cache_imag = f.read('E_imag', [1 omega_i_start 1 1],...
    [dims.component omega_i_end-omega_i_start+1 dims.y dims.x]);
  from_cache_imag_t = permute(from_cache_imag, [3 4 1 2]);
  clear from_cache_imag;
  f_t.write('E_imag', [1 1 1 omega_i_start], from_cache_imag_t);
  clear from_cache_imag_t;
  toc
end

% set finished flag in transposed file
f_t.write('finished', 1, 1);

% delete original file
delete(filename);

% move to slow storage if fast_directory in use
if ~strcmp(instance.directory, instance.fast_directory)
  source = filename_t;
  destination = fullfile(instance.directory, ['dipole_response_z' num2str(instance.zv(zi)) '_transposed' instance.extension]);

  'move to mass storage'
  tic
  movefile(source, destination);
  toc
  'move to mass storage done'
end

% empty return value (obligatory due to method_syntax_workaround)
ret = [];
