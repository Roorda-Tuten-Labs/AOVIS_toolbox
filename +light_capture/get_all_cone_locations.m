function locs = get_all_cone_locations(subject)
    if nargin < 1
        subject = '10001R';
    end

    % get location of all cones
    dat = load(['+cone_mosaic/dat/' subject '/LMS_cones.mat']);
    fnames = fieldnames(dat); %LMS_cones_10001R;
    locs = dat.(fnames{1}); 
    
    % rotate the cones to match up with imagecd
	cones = rot90(cell2mat(locs(:, 1:2)));
    cones(2, :) = max(cones(2, :)) - cones(2, :);
    
    if iscell(locs)
        tmp = locs;
        locs = zeros(length(locs), 4);
        locs(:, 1:2) = cell2mat(tmp(:, 1:2));
        locs(:, 4) = cell2mat(tmp(:, 4));
        
        locs(strcmp(tmp(:, 3), 'L'), 3) = 3;
        locs(strcmp(tmp(:, 3), 'M'), 3) = 2;
        locs(strcmp(tmp(:, 3), 'S'), 3) = 1;
    end

    locs(:, 1:2) = cones';
    
end