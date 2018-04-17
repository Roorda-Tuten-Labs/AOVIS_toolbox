function add_identified_cones(subject, find_ncones)
%
% USAGE
% add_identify_cones(subject, find_ncones)
if nargin < 1    
    subject = input('what is the subject ID');
end
if nargin < 2
    find_ncones = input('how many cones would you like to add?');
end

fdir = fileparts(which('cone_mosaic.add_identified_cones'));
im = imread(fullfile(fdir, 'cone_identify', subject, 'ref.tif'));

im = im(:, :, 1);
[cones_x, cones_y] = img.find_cones(7, im, 'auto', 0.55, 1);
cones = [cones_x, cones_y];
    
if exist(fullfile('cone_identify', subject, ...
        'cone_coord_ref_img_space.mat'), 'file')
    % will load a variable called new_cone_coords
    load(fullfile('cone_identify', subject, ...
        'cone_coord_ref_img_space.mat'));

    ncones = size(new_cone_coords, 1); %#ok!
    hold on;
    for i = 1:ncones
        cone = new_cone_coords(i, :);
        plot(cone(1), cone(2), ...
            'ob');
    end

else
    new_cone_coords = [];
end

% now select the cones of interest
hold on;
loc = zeros(find_ncones, 3);
coneN = 1;
while coneN <= find_ncones
    % get user input
    [x, y, button] = ginput(1);
    new_cone = [x, y];
    
    % act on the user input
    if button == 3 % right button click
        % remove previously selected cone
        coneN = coneN - 1;
        % get index of previously selected cone
        ind = loc(coneN, 3);
        % remove (overwrite) previous cone from plot
        plot(cones(ind, 1), cones(ind, 2), 'wo');
        % remove previous cone from locations to save later
        loc(coneN, :) = 0;
        
    elseif button == 1 % left button click
        % find selected cone from identified cones
        [nn, ~] = knnsearch(cones, new_cone, 'K', 1);
        ind = nn(:, 1);
        
        % check that the cone doesn't already exist
        if ~any(ind == loc(:, 3)) %&& ~any(ind == c_loc(:, 4))
            % add selected cone to plot to indicate to user that it has been
            % selected.
            plot(cones(ind, 1), cones(ind, 2), 'ko');
            % add selected cone to locations to save later
            loc(coneN, :) = [cones(ind, :) ind];

            % increment cone count
            coneN = coneN + 1;
            
        else
            title(['already selected cone #: ' num2str(coneN)]);
        end
        
    end
    title(['cone #: ' num2str(coneN)]);
end

% since we don't know the cone types, call them all L-cones.
cone_coords = [loc(:, 1:2) ones(length(loc(:, 1)), 1) * 3];
% add to existing new_cone_coords;
new_cone_coords = [new_cone_coords; cone_coords];

save(fullfile('cone_identify', subject, 'cone_coord_ref_img_space.mat'), ...
    'new_cone_coords');