function [x_mat, y_mat] = apply_TCA_offsets_to_locs(tca_xy, cross_xy, ...
    stim_xy, sequence_length, system)
    % [x_mat, y_mat] = apply_TCA_offsets_to_locs(tca_xy, cross_xy, stim_xy, 
    %     sequence_length)
    %
    %

    % number of stimulation locations
    num_locations = size(stim_xy, 1);

    % TCA offsets
    if strcmpi(system, 'tslo')
        tca_xy = tca_xy .*  [-1, 1];
    elseif strcmpi(system, 'aoslo')
        tca_xy = tca_xy .* [1, 1];
    else
        error('system not recognized. must be tslo or aoslo');
    end

    % Difference between locations and cross
    offsets_x_y = stim_xy - repmat(cross_xy, num_locations, 1);

    % Add TCA to the offsets
    offset_matrix_with_TCA = offsets_x_y + repmat(tca_xy, num_locations, 1);

    % Set up AOM TCA offset mats
    x_mat = zeros(sequence_length, sequence_length, num_locations);
    y_mat = zeros(sequence_length, sequence_length, num_locations);

    %%% Change back when using offsets from stabilized cone movie %%%
    for loc = 1:num_locations
        x_mat(:, :, loc) = offset_matrix_with_TCA(loc, 1);
        y_mat(:, :, loc) = offset_matrix_with_TCA(loc, 2);
    end
