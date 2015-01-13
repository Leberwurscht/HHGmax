function ret = reference_close(instance)

reference_low_level('data{varargin{1}} = [];', instance.reference);

ret = [];
