function ret = hhgmax_binary_file_fallback_create(instance)

% open file
fd = fopen(instance.filename,'w');

% fill file with nan
blocksize = 1024*1024/8; % in numbers, not bytes

numbers_written = 0;
while numbers_written<instance.total_size
  write_numbers = min(instance.total_size-numbers_written, blocksize);

  fwrite(fd, nan([1 write_numbers]), 'double');
  numbers_written = numbers_written + write_numbers;
end

% append dimensions and total size
fwrite(fd, cell2mat(struct2cell(instance.structure.dimensions)), 'uint64');
fwrite(fd, instance.total_size*8, 'uint64');

fclose(fd);

ret = [];
