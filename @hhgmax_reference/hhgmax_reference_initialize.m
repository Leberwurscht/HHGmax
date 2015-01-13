function ret = hhgmax_reference_initialize(instance, data)

hhgmax_reference_low_level('data{varargin{1}} = varargin{2};', instance.reference, data);

ret = [];
