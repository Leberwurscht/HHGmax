function resources = hhgmax_cache_ram_resources(instance)

resources = struct();
resources.disk = 0;
resources.ram = instance.xn*instance.yn*instance.zn*instance.components*instance.omegan * 8*2;
