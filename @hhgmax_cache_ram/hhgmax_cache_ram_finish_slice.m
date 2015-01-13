function ret = hhgmax_cache_ram_finish_slice(instance, zi)

instance.finished(zi) = 1;

% empty return value (obligatory due to method_syntax_workaround)
ret = [];
