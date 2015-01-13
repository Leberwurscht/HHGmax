function ret = hhgmax_reference_eval(instance, expression, varargin)

% evaluate expression
expression = strrep(expression, '<DATA>', ['data{' num2str(instance.reference) '}']);
ret = eval(expression);
