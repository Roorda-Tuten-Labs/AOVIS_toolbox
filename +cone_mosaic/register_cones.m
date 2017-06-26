function [cones_in_new_coords, nn_cone_coords] = register_cones(ref, ...
    ref_cone_coords, new_img)
    % register the cone locations from a reference image with a new image.
    % this routine will take a reference image and reference cone
    % coordinates and find them in a new image.
    %
    % USAGE
    % cones_in_new_coords = register_cones(ref, ref_cone_coords, new_img)
    %
    % INPUT
    % ref               reference image.
    % ref_cone_coords   coordinates of cones of interest in reference
    %                   image. matrix should be nx2, where n=number of
    %                   cones.
    % new_img           the image to register with reference.
    %
    % OUTPUT
    % cones_in_new_coords   location of all cones in new coordinates. the
    %                       number of cones will be the same as
    %                       ref_cone_coords (nx2). these coordinates may 
    %                       suffer from slight misalignment.
    % nn_cone_coords        location of cones of interest that could be 
    %                       reliably matched to identified cones in the new
    %                       image. 
    
    % register the two images first
    % output =  [error,diffphase,net_row_shift,net_col_shift]
    [output, ~] = img.dftregistration(fft2(ref), fft2(new_img), 100);
    
    % relative offsets (in pixels) between the two images
    offsets = output(3:4);
    
    % find cones in the new image
    [x_interest, y_interest, ~] = img.find_cones(7, new_img, 'auto', ...
        0.6, 0);
    selection_img_coords = [x_interest, y_interest];

    % find matches based on nearest neighbors
    nn_cone_coords = find_nn_matches(ref_cone_coords, ...
            selection_img_coords, offsets);

    % set up coord spaces, then translate ref into selection coords
    sel_coords = nn_cone_coords(:, 1:2);
    ref_coords = ref_cone_coords(nn_cone_coords(:, 4), 1:2);

    % translate
    ref_coords(:, 1) = ref_coords(:, 1) - offsets(2);
    ref_coords(:, 2) = ref_coords(:, 2) - offsets(1);  

    % solve linear equation
    transform_matrix = sel_coords \ ref_coords;

    % translate
    ref_cone_coords(:, 1) = ref_cone_coords(:, 1) - offsets(2);
    ref_cone_coords(:, 2) = ref_cone_coords(:, 2) - offsets(1); 

    % scale and rotate
    cones_in_new_coords = transform_matrix * ref_cone_coords(:, 1:2)';
    
    % transpose to return in the same orientation as passed coords.
    cones_in_new_coords = cones_in_new_coords';
    
    % do nn search again
%     cones_in_new_coords = [cones_in_new_coords, ref_cone_coords(:, 3)];
%     nn_cone_coords = find_nn_matches(cones_in_new_coords, selection_img_coords);
    
%     ref_coords = transform_matrix * ref_coords';
%     ref_coords = ref_coords';    
%    
%     figure; hold on;
%     plot(sel_coords(:, 1), sel_coords(:, 2), 'k.')
%     plot(ref_coords(:, 1), ref_coords(:, 2), 'ro')

    function nn_coords = find_nn_matches(ref_cone_coords, ...
            selection_img_coords, offsets, threshold)
        % nn_coords = find_nn_matches(ref_cone_coords, ...
        %               selection_img_coords, offsets, threshold)
        % 
        
        if nargin < 4
            threshold = 8;
        end
        if nargin < 3 || isempty(offsets)
            offsets = [0, 0];
        end
        
        % translate
        selection_img_ref_coords = [selection_img_coords(:, 1) + offsets(2), ...
            selection_img_coords(:, 2) + offsets(1)];    
        
        % now iterate through each possible match and select only those 
        % higher than the threshold (2-7 pix).        
        [index, distance] = knnsearch(ref_cone_coords(:, 1:2), ...
            selection_img_ref_coords);        
        nn_coords = zeros(size(ref_cone_coords));
        unique_indexes = unique(index);
        for cc = 1:length(unique_indexes)        
            ref_ind = unique_indexes(cc);
            inds = find(index == ref_ind);
            dists = distance(inds);
            % check if smallest distance is below threshold
            [mindist, ind] = min(dists);
            if mindist < threshold
                selection_ind = inds(ind);
                % x,y coord
                nn_coords(cc, 1:2) = selection_img_coords(selection_ind, :);
                % cone type
                nn_coords(cc, 3) = ref_cone_coords(ref_ind, 3);
                % reference index
                nn_coords(cc, 4) = ref_ind;
            end
        end
        nn_coords = util.remove_zero_rows(nn_coords);
    end
    
end