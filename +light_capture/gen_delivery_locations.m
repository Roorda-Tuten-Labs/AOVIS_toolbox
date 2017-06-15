function [xloc, yloc] = gen_delivery_locations(target_cone_x, target_cone_y, data)

    % convert to pixels
    delivery_std = (data.delivery_error / 60) * data.scaling;
    
    % generate list of delivery coordinates using randn 
    if ~isfield(data, 'delivery_loc')
        xloc = round(target_cone_x + delivery_std .* randn(data.numSim, 1));
        yloc = round(target_cone_y + delivery_std .* randn(data.numSim, 1));
    else
        % real data (get this from the location of the white cross in the 
        % AOSLO videos)
        
    end
end