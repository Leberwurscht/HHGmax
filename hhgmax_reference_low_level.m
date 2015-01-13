function ret = hhgmax_reference_low_level(expression, varargin)
% Used by the reference class.
% This function only exists to maintain a persistent variable and to provide
% access to it using eval.

% initialize persistent cell array containing data
persistent data;
if ~length(data)
  data = {};
end

% evaluate passed expression on data
% (this strange method to get the return value of eval is necessary in Matlab to
%  avoid error messages when expression is an assignment)
[];
eval(expression);
ret = ans;
