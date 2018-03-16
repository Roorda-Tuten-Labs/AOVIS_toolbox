% Light Capture Analysis
% Original code developed by W. Tuten, 8/26/2015

% Add ability to read in zernike files (GeneratePSF can read in
% .zer file from HSWS)
% Add ability to read in delivery locations computed from real images.
clearvars;
format compact
% used for saving data
exp_type = 'color_naming'; 
runSim = 1;

% --- General parameters
% flag that initiates the light capture simulation; skip if you've already 
params = light_capture.gen_default_params();
% subject: use '10001' or '20076' for real mosaic, otherwise 'model'
params.subject = 'model';
params.center_cone_index = 384;

% pixels per degree of the raster field; get from AOSLO calibration video
params.scaling = 545;
% standard deviation for delivery, in arcmin (average from manuscript v6)
params.delivery_error = 0.16; 
% in arcmin (aka "trial blur")
params.intratrial_delivery_error = 0.0; 
% set the defocus levels to iterate over.
params.defocus_levels = 0:0.025:0.15;
% eccentricity of tested retinal patch in degrees;
params.test_ecc = 6.0;
% shape of stimulus (hard-coded or read in from psy file)
params.stimshape = 'square';
params.stimsize = 7; % pixels
% in pixels; should correspond to number of pixels in AOSLO raster
params.imsize = 512; 
% in mm; coded here, or read in from CFG or .psy file (i.e. pupil_size = CFG.pupilsize)
params.pupil_size = 6.4;
% stimulus wavelength in microns
params.lambda = 543/1000;
% number of jittered deliveries per defocus level    
params.numSim = 10;
% random number generator seed
params.seed = 8484615;
% change this flag to 0 if you want to read in actual zernike files
% from HSWS (not used in this code)
params.diff_limited = 1; 
% trial intensity
params.trialIntensity = 1;
% inferred cone aperature: proportion of inner segment diameter 
% this sets the full-width-half-max of 2D Gaussian representing each cone
% From MacLeod, Williams, Mackous 1992
params.proportion = 0.48; 
% -----------------------------------------------------------------------

% --- Set the random number generator seed.
rng(params.seed);

% --- Setup saving dir and name
savename = light_capture.gen_save_dir_name(params, 'dat');

% --- Generate stimulus used for testing 
params = light_capture.gen_stimulus(params);

% ---- Generate PSF
% set up PSF parameters
params.field_size = params.imsize ./ params.scaling * 60; %in arcmin

%typically equal
params.psf_pupil = params.pupil_size; 
params.zernike_pupil = params.psf_pupil;

% ---------------------- %
params = light_capture.GeneratePSF(params);
params = light_capture.gen_retina_image(params);
[xi, yi, model_im, model_im_layers] = light_capture.gen_cone_array(params);

% set up data structures
ndefocus = length(params.defocus_levels);
params.def = zeros(ndefocus, 1);
params.per_trial_int = zeros(ndefocus, params.numSim);
params.per_cone_int = zeros(ndefocus, params.numSim, size(model_im_layers, 3));
params.stim_int = zeros(ndefocus, 1);
params.stim_orig = sum(params.stim_im_orig(:));

if runSim == 1
    data = {};
    index = 1;    
    % defocus in diopters; can vary this (or simulate random fluctuations)
    % to change the PSF and, subsequently, the convolved stimulus 
    % representation used to calculate light capture
    for defocus = params.defocus_levels
        
        % regenerate the PSF each iteration with new defocus level
        params.defocus = defocus;
        
        % recompute PSF and retinal image with new defocus.
        params = light_capture.GeneratePSF(params);
        params = light_capture.gen_retina_image(params);
        
        params = light_capture.model(params);
        
        % store the results
        data.def(index) = params.defocus;
        data.per_trial_int(index, :) = params.per_trial_int;
        data.per_cone_int(index, :, :) = params.per_cone_int;
        data.stim_int(index) = sum(params.retina_image(:));
        
        index = index + 1;
    end
    % save here so you don't have to re-run the simulation to do plotting;
    save([savename '.mat'], 'data' , 'model_im', 'model_im_layers', 'exp_type'); 
else
    % load in previously-generated .mat file
    [fname, pname] = uigetfile('*.mat', 'Select light capture analysis file');
    load([pname fname]);
end

% ------------- plot
% plot stimulus delivery sites in green
plotsavename = light_capture.gen_save_dir_name(params, 'img');
light_capture.plot_mosaic(model_im, ...
    params.xloc, params.yloc, xi, yi, params.halfwidth, plotsavename);

% plot the light capture analysis results
light_capture.plot_light_capture(data, plotsavename);

