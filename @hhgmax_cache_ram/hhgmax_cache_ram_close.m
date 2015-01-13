function ret = cache_ram_close(instance)

instance.data.close();
instance.finished.close();

ret = [];