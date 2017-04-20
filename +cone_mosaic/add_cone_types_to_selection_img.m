function handle = add_cone_types_to_selection_img(subject, selection_img, ...
    xy_cross_loc)
    % Add previously identified cone locations (w/ spectrial ID) to a new
    % image.
    %
    % USAGE
    % add_cone_types_to_selection_img(subject, selection_img, xy_cross_loc)
    %
    % INPUT
    % subject           subject ID
    % selection_img     image to add identified locations to
    % xy_cross_loc      optional. add the location of a delivery cross to
    %                   the selection_img. this feature is useful for
    %                   determining location of selection area relative to
    %                   the cones of interest.
    %
    % OUTPUT
    % handle            figure handle.
    %
    
    if nargin < 3
        xy_cross_loc = [];
    end
    % this is directory to reference images and cone database
    curdir = fileparts(mfilename('fullpath'));

    % load reference image
    datadir = fullfile(curdir, 'cone_identify', subject);
    ref = imread(fullfile(datadir, 'ref.tif'));

    % load cone coordinates
    ref_cone_coords = load(fullfile(datadir, 'cone_coord_ref_img_space.mat'));
    ref_cone_coords = ref_cone_coords.new_cone_coords;

    % if img comes in a color format, only look at the first dimension
    if ndims(selection_img) > 2
        selection_img = selection_img(:, :, 1);
    end

    % crop the image down
    %buffered_img = img.zero_buffer(selection_img, size(ref));
    if size(selection_img, 1) > size(ref, 1) || size(selection_img, 2) > size(ref, 2)
        center = floor(size(selection_img) ./ 2);
        refsize = size(ref);
        croprect = [(center(2) - floor(refsize(2) / 2)), ...
               (center(1) - floor(refsize(1) / 2)),...
               refsize(2) - 1, refsize(1) - 1];

        xy_cross_loc(1) =  xy_cross_loc(1) - (center(2) - floor(refsize(2) / 2));
        xy_cross_loc(2) =  xy_cross_loc(2) - (center(1) - floor(refsize(1) / 2));

        % cut the image down to speed up search   
        img_crop = imcrop(selection_img, croprect);
    end

    % register the cones with old coords
    [cones_in_new_coords, nn_cone_coords] = cone_mosaic.register_cones(...
        ref, ref_cone_coords, img_crop);
    
    % --- plot the results --- %
    handle = figure;
    if max(max(img_crop)) > 125
        imshow(img_crop, [0 255]);
    else
        imshow(img_crop)
    end
    
    hold on;
    colors = {'b' 'g' 'r'};
    % this adds all cones of interest after transformation into new
    % coordinates.
    for c = 1:size(cones_in_new_coords, 1)
        plot(cones_in_new_coords(c, 1), ...
            cones_in_new_coords(c, 2), '.', ...
            'color', colors{ref_cone_coords(c, 3)}, 'markersize', 12)
    end   
    
    % cones as found by matching them w/ nearest neighbor
    % this process will not find 10-20% of cones, but of those that it does
    % find, they will be properly centered on the cone.
    for c = 1:size(nn_cone_coords, 1)
        plot(nn_cone_coords(c, 1), nn_cone_coords(c, 2), 'o', ...
            'color', colors{nn_cone_coords(c, 3)})
    end       

    if ~isempty(xy_cross_loc)
        plot(xy_cross_loc(1), xy_cross_loc(2), 'y+', 'markersize', 25);
    end

