function instance = hhgmax_binary_file_fallback(filename, structure)

% if dimensions are missing in structure, read them from file
if any(isnan(cell2mat(struct2cell(structure.dimensions))))
  fd = fopen(filename, 'r');
  fseek(fd, -8, 'eof');
  info_pos = fread(fd, 1, 'uint64');
  fseek(fd, info_pos, 'bof');

  dim_names = fieldnames(structure.dimensions);
  dims = fread(fd, length(dim_names), 'uint64');

  for dim_i=1:length(dim_names)
    structure.dimensions.(dim_names{dim_i}) = dims(dim_i);
  end
end

instance.filename = filename;
instance.structure = structure;

instance.positions = struct();
instance.sizes = struct();

current_position = 0;
variables = fieldnames(structure.variables);
for ii=1:length(variables)
  name = variables{ii};

  instance.positions.(name) = current_position;

  vardims = instance.structure.variables.(name);

  dimlengths = [];
  for jj=1:length(vardims)
    dimlengths(jj) = instance.structure.dimensions.(vardims{jj});
  end
  instance.sizes.(name) = dimlengths;

  current_position = current_position + prod(dimlengths);
end
instance.total_size = current_position;

instance = class(instance, 'hhgmax_binary_file_fallback');
