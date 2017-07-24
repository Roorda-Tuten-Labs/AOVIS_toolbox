function [figHand1, figHand2] = delivery_error_analysis(summary_error)
% plot delivery error analysis for a directory with stabilized videos
%
% USAGE
% [figHand1, figHand2] = delivery_error_analysis(video_dir, pix_per_degree, 
%                           cross_size_pix, xcorr_thresh)
%
% INPUT
% summary_error:    matrix of already analyzed delivery errors or a 
%                   directory containing videos to analyze. 
%
% OUTPUT
% figHand1:         figure handle to first plot (delivery locations)
% figHand2:         figure handle to second plot (histogram of error 
%                   magnitude)
    

% if no delivery error matrix or path to directory is passed.
if isempty(summary_error) || ischar(summary_error)
    if ischar(summary_error)
        video_dir = summary_error;
    end
    summary_error = delivery.find_error(video_dir, cross_size_pix, ...
        xcorr_thresh, 'green', 1);
end

%summary_data = delivery.summarize_error(delivery_err, pix_per_degree);

trials = unique(summary_error(:, 1));
ntrials = length(trials);

if nargout > 0
    figHand1 = figure; 
else
    figure;
end
hold on;

for t = 1:ntrials
    trial = trials(t);
    trial_data = summary_error(summary_error(:, 1) == trial, :);
    
    % mark trials with high delivery error in red
    if trial_data(6) < 0.5
        color = 'k';
    else
        color = 'r';
    end
    % plot mean delivery location for each trial.
    plot(trial_data(:, 2), trial_data(:, 4), [color '.'], ...
        'markersize', 14);
end

if nargout
    figHand2 = figure;
else
    figure;
end
hold on;

histogram(summary_error(:, 6), 0:0.05:1.5);
plots.nice_axes('delivery error (arcmin)', 'count', 22);

end

