function ret = hhgmax_cache_file_set_point(instance, xi, yi, zi, d_omega)

% create file handle
filename = fullfile(instance.fast_directory, ['dipole_response_z' num2str(instance.zv(zi)) instance.extension]);
f = instance.backend(filename, instance.structure);

% create file if not exists
if ~exist(filename, 'file')
  f.create()
end

% get dimensions
omegan = instance.structure.dimensions.omega;
components = instance.structure.dimensions.component;

% write data
f.write('E_real', [1 1 yi xi], reshape(real(d_omega), [components omegan 1 1]));
f.write('E_imag', [1 1 yi xi], reshape(imag(d_omega), [components omegan 1 1]));

% empty return value (obligatory due to method_syntax_workaround)
ret = [];
