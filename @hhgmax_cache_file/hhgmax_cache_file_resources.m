function resources = hhgmax_cache_file_resources(instance)

xn = instance.structure.dimensions.x;
yn = instance.structure.dimensions.y;
zn = length(instance.zv);
components = instance.structure.dimensions.component;
omegan = instance.structure.dimensions.omega;

frq_component_size = xn*yn*components* 8*2;
slice_size = frq_component_size*omegan;

resources = struct();

resources.ram_get_slice_per_omega = frq_component_size;
  % get_slice reads real and imaginary part separately from file and then
  % reconstructs complex array, which at least Octave does not do with lazy
  % copying, so additional RAM is required for that.

resources.ram = max(min(instance.transpose_RAM, slice_size), omegan*components*8*2);
  % finish_slice transposes the data file for performance reasons, which will
  % consume the configured size of transpose RAM, but at most slice_size.
  % set_point will consume some RAM because of taking real/imaginary part.

if strcmp(instance.directory, instance.fast_directory)
  resources.disk_fast = 0;
  resources.disk_slow = slice_size*zn + slice_size;
    % +slice_size for transpose step
else
  resources.disk_fast = 2*slice_size; % *2 for transpose step
  resources.disk_slow = slice_size*zn;
end

resources.disk = resources.disk_fast + resources.disk_slow;
