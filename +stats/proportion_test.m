function [sigma, z_score, p_val] = proportion_test(X, null_hypothesis, ...
    two_tailed, print_results)
% Proportion test
% (http://stattrek.com/hypothesis-test/proportion.aspx?Tutorial=AP)
%
% USAGE
% [sigma, z_score, p_val] =  proportion_test(X, null_hypothesis, ...
%     two_tailed, print_results)
%
% INPUT
% X                 Input array. Array of 0s and 1s to indicate No/Yes
% null_hypothesis   Proportion of Yes expected under null hypothesis (H0).
%                   Default = 0.5.
% two_tailed        Logical. Decide whether to run a one (0) or two (1) 
%                   tailed test.
% print_results     Logical. Decide to print results or not.
%
% OUTPUT
% sigma             standard deviation of observation: sqrt(P * (1-P) / N)
% z_score           Z-score. P - H0 / sigma
% p_val             Computed from: 1 - normcdf(abs(z_score)) (one tail). 
%                                  1 - (2*normcdf(abs(z_score))) (two tail).
%
% If print_results == true, the results will be displayed in the command
% window
    
if nargin < 4 || isempty(print_results)
    print_results = 1;
end
if nargin < 3 || isempty(two_tailed)
    two_tailed = 1;
end
if nargin < 2 || isempty(null_hypothesis)
    null_hypothesis = 0.5;
end

if ~(two_tailed == 0 || two_tailed == 1)
    error('Two tailed input must be a logical (0=false, 1=true)')
end
if ~(print_results ~= 0 || print_results ~= 1)
    error('print_results input must be a logical (0=false, 1=true)')
end
    
% Number of observations
N_observations = length(X);
frac_yes = sum(X) / N_observations;
frac_no = 1 - frac_yes;

sigma = sqrt(frac_yes * frac_no / N_observations);

z_score = (frac_yes - null_hypothesis) / sigma;


if two_tailed
    p_val = 1 - (2 * normcdf(abs(z_score)));
else
    p_val = 1 - normcdf(abs(z_score));
end

if print_results
    util.pprint(N_observations, -1, 'N:')
    util.pprint(frac_yes, 4, 'P:')
    util.pprint(sigma, 4, 'StDv:')
    util.pprint(null_hypothesis, 4, 'H0:')
    util.pprint(z_score, 3, 'Z:')
    util.pprint(p_val, 6, 'p-val:')
    disp(' ');
end