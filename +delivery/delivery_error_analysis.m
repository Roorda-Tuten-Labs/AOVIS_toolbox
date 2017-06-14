function [figHand1, figHand2] = delivery_error_analysis(delivery_err, ...
    pix_per_degree, cross_size_pix, xcorr_thresh)
% plot delivery error analysis for a directory with stabilized videos
%
% USAGE
% [figHand1, figHand2] = delivery_error_analysis(video_dir, pix_per_degree, 
%                           cross_size_pix, xcorr_thresh)
%
% INPUT
% delivery_err:     matrix of already analyzed delivery errors or a 
%                   directory containing videos to analyze. if nothing or
%                   an empty string is passed, the user will be prompted to
%                   select a directory.
% pix_per_degree:   pixels/degree of the AOSLO videos. Default = 535.
% cross_size_pix:   size of the cross used in cross correlation, specified
%                   in pixels. Default = 17.
% xcorr_thresh:     threshold for finding a cross. Default = 0.5.
%
% OUTPUT
% figHand1:         figure handle to first plot (delivery locations)
% figHand2:         figure handle to second plot (histogram of error 
%                   magnitude)
    
if nargin < 1
    video_dir = '';
    delivery_err = [];
end
if nargin < 2
    pix_per_degree = 535;
end
if nargin < 3
    cross_size_pix = 17;
end
if nargin < 4
    xcorr_thresh = 0.5;
end

% if no delivery error matrix or path to directory is passed.
if isempty(delivery_err) || ischar(delivery_err)
    if ischar(delivery_err)
        video_dir = delivery_err;
    end
    delivery_err = delivery.find_error(video_dir, cross_size_pix, ...
        xcorr_thresh, 'green', 1);
end

summary_data = delivery.summarize_error(delivery_err, pix_per_degree);

trials = unique(delivery_err(:, 1));
ntrials = length(trials);

if nargout > 0
    figHand1 = figure; 
else
    figure;
end
hold on;

colors = get(gca, 'ColorOrder');
for t = 1:ntrials
    trial = trials(t);
    trial_data = delivery_err(delivery_err(:, 1) == trial, :);
    
    color = colors(mod(trial, 7) + 1, :);
    plot(trial_data(:, 3), trial_data(:, 4), '.', 'markerfacecolor', color, ...
        'markersize', 14);
end

if nargout
    figHand2 = figure;
else
    figure;
end
hold on;

histogram(summary_data(:, 6), 0:0.05:1.5);
plots.nice_axes('delivery error (arcmin)', 'count', 22);

end

