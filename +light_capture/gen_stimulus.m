function stim_im_orig = gen_stimulus(data)

    % or read in from CFG or .psy file (i.e. stimsize = CFG.stimsize)
    [stim_im_orig] = createStimulus(data.stimsize, data.stimshape, data.imsize);

    %scale stimulus by trial intensity
    stim_im_orig = stim_im_orig.*data.trialIntensity; 

    % --- Convolve stimulus image with 15-frame delivery error
    if data.intratrial_delivery_error>0;
        sigma = data.intratrial_delivery_error*(1/60)*data.scaling;

        %gaussian from fspecial only has single pixel peak if filter
        %size is odd, so add 1 pixel here and trim one pixel two lines later
        delivery_blur = fspecial('gaussian', data.imsize + 1, sigma); 

        %normalize
        delivery_blur = delivery_blur ./ max(delivery_blur(:)); 

        %trim pixel here, see above; peak of trial blur should be at (256, 256)
        delivery_blur(:,end) = []; 
        delivery_blur(end,:) = []; 

        %convolve stimulus with "trial blur"
        stim_im_orig = convolve(stim_im_orig,delivery_blur); 
    end

end