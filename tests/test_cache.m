addpath('..')

xn = 5;
yn = 5;
zv = [1 2 3 4 5];
components = 2;
omegan = 5;
zn = length(zv);

data = rand(zn,yn,xn,components,omegan);
data = data + rand(zn,yn,xn,components,omegan)*1i;

% test resources method of ram backend
c = hhgmax_cache(xn,yn,zv,components,omegan);
res = c.resources();
assert(res.disk==0);
assert(res.ram==xn*yn*zn*components*omegan*8*2);

% test open method
c.open();

% test set point method
for xi=1:xn
 for yi=1:yn
  for zi=1:zn
   c.set_point(xi, yi, zi, data(zi,yi,xi,:,:));
  end
 end
end

% test finish slice method
c.finish_slice(2);

% test get_slice method - unfinished slice
zi = 1;
got_slice = c.get_slice(zi, 1, omegan);
assert(~length(got_slice));

% test get_slice method - finished slice
zi = 2;
query_start = 2;
query_end = omegan - 1;
got_slice = c.get_slice(zi, query_start, query_end);
original = squeeze(data(zi,:,:,:,query_start:query_end));
assert(all(all(all(all(got_slice==original))))==1);

% test close method
c.close();

% test resources method of file backend
config.backend = 'netcdf';
config.directory = '/tmp/testcache';
config.fast_directory = '/tmp/testcache_fast';
config.transpose_RAM = 1;
metadata = struct('test',1);
c = hhgmax_cache(xn,yn,zv,components,omegan,config,metadata);
res = c.resources()
assert(res.disk==xn*yn*components*omegan*8*2 * (zn+2));
assert(res.ram==min(config.transpose_RAM*1e9,xn*yn*components*omegan*8*2));

% test open method
c.open();

% test set point method
for xi=1:xn
 for yi=1:yn
  for zi=1:zn
   c.set_point(xi, yi, zi, data(zi,yi,xi,:,:));
  end
 end
end

% test finish slice method
c.finish_slice(2);

% test get_slice method - unfinished slice
zi = 1;
got_slice = c.get_slice(zi, 1, omegan);
assert(~length(got_slice));

% test get_slice method - finished slice
zi = 2;
query_start = 2;
query_end = omegan - 1;
got_slice = c.get_slice(zi, query_start, query_end);
original = squeeze(data(zi,:,:,:,query_start:query_end));
assert(all(all(all(all(got_slice==original))))==1);

% test close method
c.close();
