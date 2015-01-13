function ret = hhgmax_cache_ram_close(instance)

instance.data.close();
instance.finished.close();

ret = [];
