function LMratio = get_lm_ratio(subject, print_result)
%
% USAGE
% LMratio = get_lm_ratio(subject, print_result)
%

if nargin < 2
    print_result = 1;
end
cones = cone_mosaic.load_locs(subject);

LMratio = sum(cones(:, 3) == 3) / sum(cones(:, 3) == 2);

if print_result
    util.pprint(LMratio, 3, 'LM ratio:');
end