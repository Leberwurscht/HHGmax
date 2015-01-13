function ret = subsasgn(obj, idx, val)
% map access to data contained in reference

if ~( length(idx)==1 && strcmp(idx(1).type,'()') )
  error('Only assignment of type ref(...) = ... is supported.');
end

hhgmax_reference_low_level('data{varargin{1}}(varargin{2}{:}) = varargin{3};', obj.reference, idx(1).subs, val);

ret = obj;
