function create_Ncone_stim(locs_xy, intensity, stimsize, first_frameN)
% create_Ncone_stim(locs_xy, intensity, stimsize, first_frameN)

if nargin < 4
    first_frameN = 4;
end

% force spot size to be odd.
if mod(stimsize, 2) == 0
    stimsize = stimsize + 1;
end

deltasize = (stimsize - 1) / 2;

locs_xy(:, 1) = locs_xy(:, 1) - (min(locs_xy(:, 1)) - deltasize - 1);
locs_xy(:, 2) = locs_xy(:, 2) - (min(locs_xy(:, 2)) - deltasize - 1);

% Find the furthest away points.
image_size = max(locs_xy(:));

% Add each location (cone) to the stimulus image to be displayed
stimulus = zeros(image_size, image_size);
for loc = 1:size(locs_xy)
    x = locs_xy(loc, 1);
    xs = x - deltasize:x + deltasize;   
    y = locs_xy(loc, 2);
    ys = y - deltasize:y + deltasize;   
    stimulus(xs, ys) = intensity;
end

%imshow(stimulus);

% save images
savedir = fullfile(pwd, 'tempStimulus');
util.check_for_dir(savedir);
imwrite(stimulus, fullfile(savedir, ['frame' num2str(first_frameN) '.bmp']));
