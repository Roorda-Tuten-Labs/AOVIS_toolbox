function [x, y] = data_uad(dat, names)
    % Transform data into uniform appearance diagram coordinates. Currently
    % there is no arcsine transformation. That transformation would only
    % apply to traditional hue scaling data. The x,y values returned range
    % from -1 to 1.
    
    % find indices of hue names: must correspond to columns in dat
    findstr = @(s) find(not(cellfun('isempty', strfind(names, s))));
    try
        indices = zeros(5, 1);
        indices(1) = findstr('white');
        indices(2) = findstr('red'); 
        indices(3) = findstr('green');
        indices(4) = findstr('blue');
        indices(5) = findstr('yellow');
    catch Me
        error('names variable must contain red, green, blue and yellow');
    end
    
    % convert numbers to red, green, blue, yellow, white
    red = sum(dat == indices(2), 2);
    green = sum(dat == indices(3), 2);
    blue = sum(dat == indices(4), 2);
    yellow = sum(dat == indices(5), 2);
    white = sum(dat == indices(1), 2);
    % compute the total for each observation (w, r, g, b, y);
    tot = red + green + blue + yellow + white;
    
    % x dimension is blue (negative) yellow (positive)
    x = (yellow - blue) ./ tot;
    
    % y dimension is red (negative) green (positive)
    y = (green - red) ./ tot;

end