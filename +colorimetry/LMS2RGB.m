function RGB = LMS2RGB(LMS, primaries_path)
% RGB = LMS2RGB(LMS, primaries)
% 
% LMS = values to convert to RGB
% primaries_name = name of primaries to be assumed in conversion
% between RGB and LMS.
%
% Returns:
% ========
% RGB = RGB values for desired primaries
%
if nargin < 2
    % If not given, just load default primaries
    primaries_path = 'lacie';
end
primaries = get_norm_primaries(primaries_path);

minLambda = min(primaries(:, 1));
maxLambda = max(primaries(:, 1));

[cones, ~] = get_fundamentals('stockman2', 1, [minLambda ...
                    maxLambda]);
cones = 10 .^ cones;

sysM = zeros(3, 3);
for row = 1:3
    for column = 1:3
        product = cones(:, row) .* primaries(:, column + 1);
        sysM(row, column) = sum(product);
    end
end

RGB = sysM \ LMS;