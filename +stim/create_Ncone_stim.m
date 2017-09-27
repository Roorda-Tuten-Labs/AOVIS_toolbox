function create_Ncone_stim(locs_xy, max_locs_xy, intensity, stimsize, ...
   frameN, extension)
% create_Ncone_stim(locs_xy, max_locs_xy, intensity, stimsize, ...
%    frameN)
%
%

if nargin < 5
    frameN = 4;
end
if nargin < 6
    extension = 'buf';
end

% force spot size to be odd.
if mod(stimsize, 2) == 0
    stimsize = stimsize + 1;
end
% halfwidth of stimulus
deltasize = floor(stimsize / 2);

% add each location (cone) to the stimulus image to be displayed
stimulus = zeros(max_locs_xy(1), max_locs_xy(2));
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
stimulus = flipud(rot90(stimulus));

%imshow(stimulus);

% save images
savedir = fullfile(pwd, 'tempStimulus');
util.check_for_dir(savedir);
if strcmpi(extension, 'bmp')
    imwrite(stimulus, fullfile(savedir, ['frame' num2str(frameN) ...
        '.bmp']));
elseif strcmpi(extension, 'buf')
    stim.write_to_buf_file(stimulus, frameN, savedir, ...
        'frame')
end
