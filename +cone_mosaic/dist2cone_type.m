function dist = dist2cone_type(mosaic, cones, cone_type, Ncones)
    % Find the distance to a specified cone type for a set of cones of  
    % interest.
    %
    % USAGE
    % dist2cone_type(mosaic, cones, cone_type, Ncones) 
    %
    % INPUT
    % mosaic:       x,y location of cones in an mosaic and cone types.
    %               should follow the pattern of cone_mosaic.load_locs.
    % cones:        x, y locations of cones of interest.
    % cone_type:    type of cones to search for.
    % Ncones:       number of nearest cones of X type to search for.
    %               default = 1.
    %
    % OUTPUT
    % dist:         distances of each cone of interest (cones) to the
    %               cone_type specified. distances returned in units of the
    %               mosaic variable; typically pixels.
    %
    

    if nargin < 4
        Ncones = 1;
    end
    
    if ischar(cone_type)
        if strcmpi(cone_type, 'l')
            cone_type = 3;
        elseif strcmpi(cone_type, 'm')
            cone_type = 2;
        elseif strcmpi(cone_type, 's')
            cone_type = 1;
        else
            error('cone_type not understood.');
        end
    end
    
    % select submosaic of desired cone type
    submosaic = mosaic(mosaic(:, 3) == cone_type, :);
    [~, dist] = knnsearch(submosaic(:, 1:2), cones, 'k', Ncones);


end