function params = gen_retina_image(params)
    %
    % Convolve PSF with stimulus and crop resulting image so that you can
    % jitter its position more easily
    diff_im = util.convolve(params.stim_im_orig, params.PSF);
    stim_im_tmp = im2double(diff_im);

    % peak row and column of convolved stimulus
    [pr, pc] = find(stim_im_tmp==max(stim_im_tmp(:))); 

    params.retina_image = stim_im_tmp(pr - params.halfwidth:pr + ...
        params.halfwidth, pc - params.halfwidth:pc + params.halfwidth);    
end