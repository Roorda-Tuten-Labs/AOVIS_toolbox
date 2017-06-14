function retina_image = gen_retina_image(stimulus, PSF, halfwidth)

    % Convolve PSF with stimulus and crop resulting image so that you can
    % jitter its position more easily
    diff_im = util.convolve(stimulus, PSF);
    stim_im_tmp = im2double(diff_im);

    % peak row and column of convolved stimulus
    [pr, pc] = find(stim_im_tmp==max(stim_im_tmp(:))); 

    retina_image = stim_im_tmp(pr - halfwidth:pr + halfwidth, ...
        pc - halfwidth:pc + halfwidth);
    
end