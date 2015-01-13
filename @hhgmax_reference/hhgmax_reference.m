function instance = hhgmax_reference(data)
% THE PROBLEM:
%   There is no efficient equivalent to passing arguments by reference to a
%   function which is both compatible to Matlab and Octave, like this:
%     large_array = zeros([1000 1000 1000])
%     modify_array(&large_array)
%
%   This is due to the copy-on-write behaviour of the Matlab language. The pro-
%   posed way to do it would be
%     large_array = modify_array(large_array),
%   but this is not efficient as the interpreter does not notice that it can do
%   the operation in-place without copying large_array (at least some versions).
%   One solution would be Matlab's handle classes, but Octave does not support
%   it.
%
% WORKAROUND:
%   Emulate references to numeric arrays using a persistent variable. This
%   function provides the following interface:
%
%     > % create new reference
%     > large_array_ref = hhgmax_reference(zeros([1000 1000 100]));
%     >
%     > % modify data on the reference (modify array_reference is arbitrary function)
%     > modify_array_reference(large_array_ref);
%     >
%     > % get data on the reference
%     > val = large_array_ref(30,20,10);
%     >
%     > % close the reference
%     > ref = ref.close();
%
%   The ref variable can be passed to functions without overhead, it is just a
%   struct containing a single integer. The function modify_array_reference
%   could look like this:
%
%     > function modify_array_reference(ref)
%     >   ref(30,20,10) = 15;
%     > end
%
%   Methods:
%     ref.size()
%     ref.initialize(data)
%     ref.eval(expression, ...), where the internal data can be accessed
%       using <DATA>, e.g. `x = ref.eval('<DATA> + varargin{1}', ones(10,10));`
%     ref.close()
%
%   Note: The current implementation only supports numeric arrays as contained
%         data, no other types like structs or cell arrays.
%

% default value for data
if ~exist('data','var')
  data = [];
end

% check input data type
if ~isnumeric(data)
  error('Only references to numeric arrays supported.');
end

% get reference
hhgmax_reference_low_level('data{length(data)+1} = varargin{1};', data);
instance.reference = hhgmax_reference_low_level('length(data);');

% convert struct to class instance
instance = class(instance, 'hhgmax_reference');
