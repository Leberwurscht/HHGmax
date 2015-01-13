function ret = subsref(instance, idx)
% map instance.method(...) to classname_method(instance,...)
% map all other access types to data contained in reference

hhgmax_method_syntax_workaround

if ~( length(idx)==2 && strcmp(idx(1).type,'.') && strcmp(idx(2).type,'()') )
  ret = hhgmax_reference_low_level('subsref(data{varargin{1}}, varargin{2});', instance.reference, idx);
end
