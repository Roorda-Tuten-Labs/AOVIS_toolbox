function output = stevens_law(x, params, type)
% output = stevens_law(x, params, type)
%
%
if nargin < 3
    type = 1;
end
if ~isstruct(params)
    if length(params) == 3
        p.k = params(1);
        p.x0 = params(2);
        p.n = params(3);
    else
        raise('params must be a struct with fields k, x0 and n or a 3x1 vector');
    end
else
    p = params;
end

if type == 1
    output = p.k .* (x - p.x0) .^ p.n;
    output = real(output);
    output(output < 0) = 0;
end