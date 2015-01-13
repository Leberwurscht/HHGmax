function ret = hhgmax_cache_ram_open(instance)

data_size = [instance.zn,instance.yn,instance.xn,instance.components,instance.omegan];
instance.data.initialize( complex(nan(data_size),nan(data_size)) );

instance.finished.initialize( zeros([1 instance.zn]) ); % for marking z slices as finished

ret = [];
