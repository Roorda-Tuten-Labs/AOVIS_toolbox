function params = compute_field_size(params)
    %
    % in degrees
    params.field_size = params.imsize ./ params.scaling  * 60; 
end