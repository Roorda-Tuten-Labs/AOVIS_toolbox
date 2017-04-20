function handle = add_cone_types_to_selection_img(subject, selection_img, ...
    xy_cross_loc)
    % add_cone_types_to_selection_img(subject, selection_img, xy_cross_loc)
    %
    %
    
    if nargin < 3
        xy_cross_loc = [];
    end
    % this is for testing the routine
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

    % output =  [error,diffphase,net_row_shift,net_col_shift]
    [output, ~] = img.dftregistration(fft2(ref), fft2(img_crop), 1);
    
    [x_interest, y_interest, ~] = img.find_cones(7, img_crop, 'auto', 0.6, 0);
    
    % relative offsets (in pixels) between the two images
    offsets = output(3:4);
    
    selection_img_coords = [x_interest, y_interest];
    selection_img_ref_coords = [x_interest + offsets(2), ...
        y_interest + offsets(1)];

    [index, distance] = knnsearch(ref_cone_coords(:, 1:2), ...
        selection_img_ref_coords);
    
    % now iterate through each possible match and select only those higher
    % than the threshold (2-7 pix).
    cone_coords = zeros(size(ref_cone_coords));
    unique_indexes = unique(index);
    for c = 1:length(unique_indexes)        
        ref_ind = unique_indexes(c);
        inds = find(index == ref_ind);
        dists = distance(inds);
        % check if smallest distance is below threshold
        [mindist, ind] = min(dists);
        if mindist < 7
            selection_ind = inds(ind);
            cone_coords(c, 1:2) = selection_img_coords(selection_ind, :);
            cone_coords(c, 3) = ref_cone_coords(ref_ind, 3);
            cone_coords(c, 4) = ref_ind;
        end
    end
    cone_coords = util.remove_zero_rows(cone_coords);
    
    % set up coord spaces, then translate ref into selection coords
    sel_coords = cone_coords(:, 1:2);
    ref_coords = ref_cone_coords(cone_coords(:, 4), 1:2);
   
    ref_coords(:, 1) = ref_coords(:, 1) - offsets(2);
    ref_coords(:, 2) = ref_coords(:, 2) - offsets(1);  
    
    % solve linear equation
    transform_matrix = sel_coords \ ref_coords;

%     ref_coords = transform_matrix * ref_coords';
%     ref_coords = ref_coords';    
%    
%     figure; hold on;
%     plot(sel_coords(:, 1), sel_coords(:, 2), 'k.')
%     plot(ref_coords(:, 1), ref_coords(:, 2), 'ro')

    % translate
    ref_cone_coord = ref_cone_coords(:, 1:2);
    ref_cone_coord(:, 1) = ref_cone_coord(:, 1) - offsets(2);
    ref_cone_coord(:, 2) = ref_cone_coord(:, 2) - offsets(1); 

    % scale and rotate
    class_cones_in_new_coords = transform_matrix * ref_cone_coord(:, 1:2)';
    class_cones_in_new_coords = class_cones_in_new_coords';
    
    % plot the results
    handle = figure;
    if max(max(img_crop)) > 125
        imshow(img_crop, [0 255]);
    else
        imshow(img_crop)
    end
    
    hold on;
    colors = {'b' 'g' 'r'};
    for c = 1:size(class_cones_in_new_coords, 1)
        plot(class_cones_in_new_coords(c, 1), ...
            class_cones_in_new_coords(c, 2), '.', ...
            'color', colors{ref_cone_coords(c, 3)}, 'markersize', 12)
    end   
    
    for c = 1:size(cone_coords, 1)
        plot(cone_coords(c, 1), cone_coords(c, 2), 'o', ...
            'color', colors{cone_coords(c, 3)})
    end       
        
%     figure; hold on;
%     plot(cone_coords(:, 1), cone_coords(:, 2), 'r.')
%     plot(class_cones_in_new_coords(:, 1), ...
%         class_cones_in_new_coords(:, 2), 'k.')

    if ~isempty(xy_cross_loc)
        plot(xy_cross_loc(1), xy_cross_loc(2), 'y+', 'markersize', 25);
    end

