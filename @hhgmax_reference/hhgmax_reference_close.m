function ret = hhgmax_reference_close(instance)

hhgmax_reference_low_level('data{varargin{1}} = [];', instance.reference);

ret = [];
