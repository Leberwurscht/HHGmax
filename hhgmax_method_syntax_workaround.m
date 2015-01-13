% THE PROBLEM:
%   Octave and old versions of Matlab do not provide a way to use the common
%   syntax for calling methods: instance.method_name(arguments)
%   Both provide basic support for object-oriented programming using
%   @-directories, and require you to call methods like this:
%     method_name(instance, arguments)
%
% WORKAROUND:
%   It is however possible to provide access over the common syntax overriding
%   the . operator on classes. This can be done by defining a method on the
%   class with the name subsref.
%   To make a class provide its methods using the common syntax, just add a file
%   subsref.m to the class directory with the following content:
%
%     function ret = subsref(instance, idx)
%     % map instance.method(...) to classname_method(instance,...)
%     hhgmax_method_syntax_workaround
%
%   Note: Methods without a return value are not supported, you always must
%         return something. However, you can use an empty value like [].

if length(idx)==2 && strcmp(idx(1).type,'.') && strcmp(idx(2).type,'()')
  method = idx(1).subs;
  function_name = [class(instance) '_' method];
  if ~ismethod(instance, function_name)
    error('invalid method');
  end
  function_handle = str2func(function_name);

  args = idx(2).subs;
  ret = function_handle(instance, args{:});
end
