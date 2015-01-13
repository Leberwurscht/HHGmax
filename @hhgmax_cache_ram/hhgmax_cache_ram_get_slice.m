function slice = hhgmax_cache_ram_get_slice(instance, zi, query_start, query_end)

if instance.finished(zi)
  slice = instance.data(zi,:,:,:,query_start:query_end);
  slice = reshape(slice, [instance.yn, instance.xn, ...
                          instance.components, query_end-query_start+1]);
else
  slice = [];
end
