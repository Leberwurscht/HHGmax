function ret = reference_size(instance)

ret = reference_low_level('size(data{varargin{1}});', instance.reference);
