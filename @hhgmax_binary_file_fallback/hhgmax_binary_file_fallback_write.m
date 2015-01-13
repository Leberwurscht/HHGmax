function data = hhgmax_binary_file_fallback_write(instance, variable, start, data)

% open file
fd = fopen(instance.filename,'r+');

% get count
ndims = length( instance.structure.variables.(variable) );
count = size(data);
count(end+1:ndims) = 1;
count = count(1:ndims);

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

% initialize index for accessing data array
idx = num2cell(repmat(':',1,ndims));

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

  % write to file
  fwrite(fd, data(idx{:}), 'double');

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
