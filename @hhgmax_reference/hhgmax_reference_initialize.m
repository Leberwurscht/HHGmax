function ret = reference_initialize(instance, data)

reference_low_level('data{varargin{1}} = varargin{2};', instance.reference, data);

ret = [];
