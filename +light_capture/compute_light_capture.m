function [per_trial_int, per_cone_int] = compute_light_capture(retina_image, ...
    delivery_x, delivery_y, model_im_layers, model_im, halfwidth)

    ndeliveries = size(delivery_x, 1);
    ncones = size(model_im_layers, 3);
    
    % set up data structures
    per_trial_int = zeros(ndeliveries, 1);
    per_cone_int = zeros(ndeliveries, ncones);
    
    % sum the retina image for normalizing
    sum_retina_image = sum(retina_image(:));
    
    % cycle through each cross location to calculate overall light capture
    % by the whole mosaic
    for n = 1:ndeliveries
        
        % create canvas in which to drop convolved stimulus
        blank_im = zeros(512, 512, ncones);
        
        % place stimulus image at stimulus location (can be jittered)
        for j = 1:ncones
            blank_im(delivery_y(n) - halfwidth:delivery_y(n) + halfwidth, ...
                delivery_x(n) - halfwidth:delivery_x(n) + halfwidth, j) = retina_image;
        end
        % image depicting light captured during this frame/trial
        light_int_trial = blank_im(:, :, 1) .* model_im; 

        % proportion of light captured by entire model cone array
        current_per_trial_int = sum(light_int_trial(:)) / sum_retina_image;
        per_trial_int(n) = current_per_trial_int;
        
        % calculate per cone light capture for each cross location
        % total light captured during this frame/trial
        light_int_cone = blank_im .* model_im_layers; 

        % proportion of light captured by this particular cone
        per_cone_int(n, :) = (sum(sum(light_int_cone, 1), 2) ./ ...
            sum_retina_image) ./ current_per_trial_int;

    end
