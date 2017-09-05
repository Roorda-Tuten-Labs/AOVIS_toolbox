function create_Ncone_stim_routine(locs_xy, intensity, stimsize, first_frameN)
% create_Ncone_stim(locs_xy, intensity, stimsize, first_frameN)
%
%

if nargin < 4
    first_frameN = 4;
end

% force spot size to be odd.
if mod(stimsize, 2) == 0
    stimsize = stimsize + 1;
end

% halfwidth of stimulus
deltasize = floor(stimsize / 2);

% find pixels in relative space
locs_xy(:, 1) = locs_xy(:, 1) - (min(locs_xy(:, 1)) - deltasize - 1);
locs_xy(:, 2) = locs_xy(:, 2) - (min(locs_xy(:, 2)) - deltasize - 1);

% add each location (cone) to the stimulus image to be displayed
stimulus = zeros(max(locs_xy(:, 1)), max(locs_xy(:, 2)));
for loc = 1:size(locs_xy)
    % find x position
    x = locs_xy(loc, 1);
    xs = x - deltasize:x + deltasize;   
    % find y position
    y = locs_xy(loc, 2);
    ys = y - deltasize:y + deltasize;   
    
    % add location to stimulus with given intensity
    stimulus(xs, ys) = intensity;
end

% change from x, y cartesian space to image space with 0,0 at top left.
stimulus = rot90(stimulus);

%imshow(stimulus);

% save images
savedir = fullfile(pwd, 'tempStimulus');
util.check_for_dir(savedir);
imwrite(stimulus, fullfile(savedir, ['frame' num2str(first_frameN) '.bmp']));
