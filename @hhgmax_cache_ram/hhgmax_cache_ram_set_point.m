function ret = hhgmax_cache_ram_set_point(instance, xi, yi, zi, d_omega)

instance.data(zi,yi,xi,:,:) = d_omega;

% empty return value (obligatory due to method_syntax_workaround)
ret = [];
