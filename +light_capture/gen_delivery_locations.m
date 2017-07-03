function [xloc, yloc] = gen_delivery_locations(target_cone_x, target_cone_y, data)
    
    % generate list of delivery coordinates using randn 
    if ~isfield(data, 'delivery_locs')
        % convert to pixels
        delivery_std = (data.delivery_error / 60) * data.scaling;  
        
        xloc = round(target_cone_x + delivery_std .* randn(data.numSim, 1));
        yloc = round(target_cone_y + delivery_std .* randn(data.numSim, 1));
    else
        % real data (get this from the location of the white cross in the 
        % AOSLO videos). specified in system pixels, centered in the middle
        % of the 512x512 raster.
        xloc = round(data.delivery_locs(:, 1) + (data.imsize / 2));
        yloc = round(data.delivery_locs(:, 2) + (data.imsize / 2));
    end
end