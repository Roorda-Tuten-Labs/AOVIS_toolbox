function data = model(params)
%

% --- check default params, etc.
data = light_capture.check_params(params);

% --- Set the random number generator seed.
rng(data.seed, 'twister');

% --- compute field size for PSF comp later
if ~isfield(data, 'field_size')    
    data = light_capture.compute_field_size(data);
end

% --- Generate stimulus used for testing 
if ~isfield(data, 'stim_im_orig')
    data.stim_im_orig = light_capture.gen_stimulus(data);
end

% ---- Generate PSF
% set up PSF parameters

% regenerate the PSF each iteration with new defocus level
if ~isfield(data, 'PSF')
    data.PSF = light_capture.GeneratePSF(data);
end

% get retinal image
if ~isfield(data, 'retina_image')
    data.retina_image = light_capture.gen_retina_image(data);
end

% --- Generate cone array
[xi, yi, model_im, model_im_layers] = light_capture.gen_cone_array(data);

% --- Get delivery locations
% Place convolved stimulus at each delivered location and calculate
% light capture in each cone;
[data.xloc, data.yloc] = light_capture.gen_delivery_locations(xi(1), yi(1), ...
    data);

[per_trial_int, per_cone_int] = light_capture.compute_light_capture(...
    data.retina_image, data.xloc, data.yloc, model_im_layers, model_im, ...
    data.halfwidth);

% N simulations (or deliveries/frames), cone of interest + 20 nearest 
% neighbors.
data.per_cone_int = per_cone_int;    
data.per_trial_int = per_trial_int;

