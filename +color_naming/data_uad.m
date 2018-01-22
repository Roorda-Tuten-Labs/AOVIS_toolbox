function [x, y] = data_uad(dat, names, arcsine_transform, ...
    independent_saturation, max_sat_val)
    % Transform hue and saturation data into UAD space. Saturation can be
    % scaled independently or simultaneously with hue. By default we assume
    % hue was scaled on a 5 button press scale and saturation was on a 0:6
    % scale.
    %
    % USAGE
    % [x, y] = data_uad(dat, names, arcsine_transform, 
    %                   independent_saturation, max_sat_val)
    %
    % INPUT
    % dat                       Data matrix. Each row should contain data
    %                           from a separate trial. If saturation was
    %                           judged independent of hue, the first column
    %                           is assumed to be that rating. In this case,
    %                           hue values will be scaled according to
    %                           saturation judgment.
    %
    % names                     color names. Default assumption:
    %                           {'red', 'green', 'blue', 'yellow', 'white'}
    %                           The position of each hue is used to
    %                           associate numerical values with hues. E.g.
    %                           11111 = 5 reds.
    %
    % arcsine_transform         Transform data into uniform appearance 
    %                           diagram coordinates. Currently there is no 
    %                           arcsine transformation by default. 
    %
    % independent_saturation    Indicate whether saturation was rated
    %                           independently of hue. If a value is not
    %                           passed, we will make a guess by assuming
    %                           that hue is always rated with an odd number
    %                           of button presses. Therefore, if we get an
    %                           even number of button presses, we assume
    %                           that the first column is saturation and it
    %                           was done independently.
    %
    % max_sat_val               Maximum saturation values. By default we
    %                           assume saturation was scaled between 0-6.
    %
    % OUTPUT
    % x, y                      (x) green-red and (y) blue-yellow axes. The
    %                           axes are scaled between -1:1.

    if nargin < 2 || isempty(names)
        names = {'red', 'green', 'blue', 'yellow', 'white'};
    end
    
    if nargin < 3 || isempty(arcsine_transform)
        arcsine_transform = false;
    end
    if nargin < 5|| isempty(max_sat_val)
        % assume saturation was rating on a scale from 0-6
        max_sat_val = 6;
    end
    
    if nargin < 4
        % if the variable is not passed, make an educated guess about
        % whether or not saturation was scaled independently.
        
        % color vector from given trial
        [~, nscale] = size(dat);
        
        % i.e. is even in length (independent sat judgment)
        if mod(nscale, 2) == 0            
            nscale = nscale - 1;
            independent_saturation = 1;
        else 
            independent_saturation = 0;
        end
        
        % now change data accordingly
        if independent_saturation
            % in this case saturation (white) is in column 1
            white = nscale  .* ((max_sat_val - dat(:, 1)) ./ max_sat_val); 
            % now that we saved white responses, clip those off
            dat = dat(:, 2:end);
        else
            white = sum(dat == 5);
        end        
    end
    
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
    
    if arcsine_transform
        % arcsine transform data and then find which cols correspond to
        % which colors
        hues = color_naming.arcsine_transform(dat);
        red = hues(:, indices(2));
        green = hues(:, indices(3));
        blue = hues(:, indices(4));
        yellow = hues(:, indices(5));
        if ~independent_saturation
            white = hues(:, indices(1));
        end
    else
        % convert numbers to red, green, blue, yellow, white
        red = sum(dat == indices(2), 2);
        green = sum(dat == indices(3), 2);
        blue = sum(dat == indices(4), 2);
        yellow = sum(dat == indices(5), 2);
        
        if independent_saturation   
            % if saturation was scaled independently, we need to rescale
            % the hue values taking saturation judgment into account:
            nonwhite = 1 - (white / nscale);
            red = red .* nonwhite;
            green = green .* nonwhite;
            blue = blue .* nonwhite;
            yellow = yellow .* nonwhite;
        end        
        if ~independent_saturation            
            white = sum(dat == indices(1), 2);              
        end
    end
    
    % compute the total for each observation (w, r, g, b, y);
    total = red + green + blue + yellow + white;
    
    % check for errors
    if total ~= nscale && total ~= 0
        error('Color values not computed properly. Must sum to Nscale');
    end    
    
    % x dimension is blue (negative) yellow (positive)
    x = (yellow - blue) ./ total;
    
    % y dimension is red (negative) green (positive)
    y = (green - red) ./ total;

end