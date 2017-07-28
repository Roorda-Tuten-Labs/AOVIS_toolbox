clearvars;

subject = '20092L';
find_ncones = 8;

if exist(fullfile('cone_identify', subject, ...
        'cone_coord_ref_img_space.mat'), 'file');
    % will load a variable called new_cone_coords
    load('cone_coord_ref_img_space.mat');

    ncones = size(new_cone_coords, 2);
    for i = 1:ncones
        cone = new_cone_coords(i, :);
        plot(cone(1), cone(2), ...
            'ob');
    end

else
    im = imread(fullfile('cone_identify', subject, 'ref.tif'));
    im = im(:, :, 1);
    [cones_x, cones_y] = img.find_cones(9, im, 'auto', 0.6, 1);
    cones = [cones_x, cones_y];
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
        [nn, d] = knnsearch(cones, new_cone, 'K', 1);
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
new_cone_coords = [loc(:, 1:2) ones(length(loc(:, 1)), 1) * 3];

save(fullfile('cone_identify', subject, 'cone_coord_ref_img_space.mat'), ...
    'new_cone_coords');