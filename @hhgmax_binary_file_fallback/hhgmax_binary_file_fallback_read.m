function data = hhgmax_binary_file_fallback_read(instance, variable, start, count)

% preallocate
if length(count)==1
  data = nan(1,count);
else
  data = nan(count);
end

% open file
fd = fopen(instance.filename,'r');

% get position and dimensions
pos = instance.positions.(variable);
dims = instance.sizes.(variable);

% invert everything due to Matlab's memory layout
dims = flipud(dims(:));
start = flipud(start(:));
count = flipud(count(:));

% check count
if ~all(start+count-1<=dims)
  error('start+count-1>dims');
end

% initialize pointer and compute block offset
seek_over = find(count~=dims, 1, 'last')-1;
if ~length(seek_over)
  seek_over = 0;
end
pointer = start(1:seek_over);
block_offset = (start(seek_over+1)-1) * prod(dims(seek_over+2:end));

% compute block shape and size
block_shape = flipud(count(seek_over+1:end))';
if length(block_shape)==1
  % reshape in Matlab not possible with one-dimensional size vector
  block_shape = [1 block_shape];
end
block_size = prod(block_shape);

% initialize data_left
data_left = prod(count);

% initialize index for accessing data array
idx = num2cell(repmat(':',1,length(dims)));

while 1
  % seek to correct file position
  offset = 0;
  for ii=seek_over:-1:1
    offset = offset + (pointer(ii)-1) * prod(dims(ii+1:end));
  end
  offset = offset + block_offset;
  offset = pos + offset;
  offset = offset * 8;
  fseek(fd, offset, 'bof');

  % construct index for accessing data array
  for ii=1:seek_over
    idx{end-ii+1} = pointer(ii)-start(ii)+1;
  end

  % read from file
  block = fread(fd, block_size, 'double');
  data(idx{:}) = reshape(block, block_shape);

  % increment pointer
  increment_pos = find(pointer<start(1:seek_over)+count(1:seek_over)-1, 1, 'last');
  if ~length(increment_pos)
    break
  end
  pointer(increment_pos) = pointer(increment_pos)+1;
  pointer(increment_pos+1:seek_over) = start(increment_pos+1:seek_over);
end

% close file
fclose(fd);
