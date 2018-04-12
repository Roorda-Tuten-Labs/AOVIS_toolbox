function LMS = RGB2LMS(RGB, primaries_name)
% LMS = RGB2LMS(RGB)
% 
% RGB = values to convert to LMS
% primaries_name = name of primaries to be assumed in conversion
% between RGB and LMS.
%
% Returns:
% ========
% LMS = LMS values
%
if nargin < 2
    % If not given, just load default primaries
    primaries_name = 'lacie';

end
primaries = colorimetry.get_norm_primaries(primaries_name);

minLambda = min(primaries(:, 1));
maxLambda = max(primaries(:, 1));

[cones, ~] = colorimetry.get_fundamentals('stockman2', 1, [minLambda ...
                    maxLambda]);
cones = 10 .^ cones;

sysM = zeros(3,3);
for row = 1:3
    for column = 1:3
        product = cones(:, row) .* primaries(:, column+1);
        sysM(row, column) = sum(product);
    end
end

LMS = sysM * RGB;
