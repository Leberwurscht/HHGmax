function ret = hhgmax_reference_size(instance)

ret = hhgmax_reference_low_level('size(data{varargin{1}});', instance.reference);
