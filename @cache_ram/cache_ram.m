function instance = cache_ram(xn,yn,zv,components,omegan)

instance.data = reference();
instance.finished = reference(); % for marking z slices as finished

% set dimensions to be able to access in cache_ram_open
instance.xn = xn;
instance.yn = yn;
instance.zn = length(zv);
instance.components = components;
instance.omegan = omegan;

instance = class(instance, 'cache_ram');
