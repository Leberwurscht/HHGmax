function instance = hhgmax_cache_ram(xn,yn,zv,components,omegan)

instance.data = hhgmax_reference();
instance.finished = hhgmax_reference(); % for marking z slices as finished

% set dimensions to be able to access in hhgmax_cache_ram_open
instance.xn = xn;
instance.yn = yn;
instance.zn = length(zv);
instance.components = components;
instance.omegan = omegan;

instance = class(instance, 'hhgmax_cache_ram');
