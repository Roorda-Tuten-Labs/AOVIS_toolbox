function summary = summarize_error(delivery_err, pix_per_degree)
% summarize delivery error over each trial
% 
% USAGE
% summary = summarize_error(delivery_err, pix_per_degree)
%
% INPUT
% delivery_err:     matrix with analyzed delivery errors from
%                   delivery.find_error() routine.
% pix_per_degree:   for converting to arcmins.
%
% OUTPUT
% summary:          n by 4 matrix. each row in the matrix corresponds to a 
%                   single frame or trial. the columns of the matrix are 
%                   organized as follows: [x mean, x std, y mean, y std].
%                   All values are returned in arcmins
%
trials = unique(delivery_err(:, 1));
ntrials = length(trials);

summary = zeros(ntrials, 6);
for t = 1:ntrials
    trial = trials(t);
    trial_data = delivery_err(delivery_err(:, 1) == trial, :);
    
    % summarize and save.
    summary(t, 1) = trial;    
    summary(t, 2) = mean(trial_data(:, 3)); % X
    summary(t, 3) = std(trial_data(:, 3)); % X
    summary(t, 4) = mean(trial_data(:, 4)); % Y
    summary(t, 5) = std(trial_data(:, 4)); % Y
    
    % convert to polar.
    [~, radius] = cart2pol(trial_data(:, 3) - summary(t, 2), ...
        trial_data(:, 4) - summary(t, 4));

    % find the mean distance
    summary(t, 6) = mean(radius);

end

% threshold out zero values (impossible)
% summary(summary(:, 5) > 75, 5) = nan;

% convert to arcmin
summary(:, 6) = summary(:, 6) .* (1 / pix_per_degree * 60);

% print summary information
disp(['mean: ' num2str(round(nanmean(summary(:, 6)), 4)) ' arcmin']);
disp(['std:  ' num2str(round(nanstd(summary(:, 6)), 4)) ' arcmin']);
disp(['N:    ' num2str(sum(~isnan(summary(:, 6))))]);