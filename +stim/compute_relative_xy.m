function [locs_relative_xy, max_size_xy] = compute_relative_xy(stimsize,...
        stim_offsets_xy)
    % [locs_relative_xy, max_size_xy] = compute_relative_xy(stimsize,...
    %    stim_offsets_xy)
    %

    % halfwidth of stimulus:: Needs to be accounted for when placing the
    % stimulus in a relative space.
    deltasize = floor(stimsize / 2);

    % find cone locations in relative space
    % need to make sure that min xy position is 1 + delta size, i.e. for a
    % three pixel stim, min xy value is 2
    locs_relative_xy(:, 1) = stim_offsets_xy(:, 1) - ...
        (min(stim_offsets_xy(:, 1)) - deltasize - 1);
    locs_relative_xy(:, 2) = stim_offsets_xy(:, 2) - ...
        (min(stim_offsets_xy(:, 2)) - deltasize - 1);

    % find max pixels in relative space
    % need to add buffer to account for 1/2 size of the stimulus itself.
    % i.e., canvas needs to be max position + deltasize in x,y
    max_size_xy = [max(locs_relative_xy(:, 1)) + deltasize, ...
        max(locs_relative_xy(:, 2)) + deltasize];