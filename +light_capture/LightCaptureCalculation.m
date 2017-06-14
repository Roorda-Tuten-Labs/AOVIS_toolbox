% Light Capture Analysis
% Original code developed by W. Tuten, 8/26/2015

% Add ability to read in zernike files (GeneratePSF can read in
% .zer file from HSWS)
% Add ability to read in delivery locations computed from real images.
clearvars;
format compact

% --- General parameters
% flag that initiates the light capture simulation; skip if you've already 
% got a simulation data file you can load in
runSim = 1; 
% used for saving data
exp_type = 'color_naming'; 
% subject: use '10001' or '20076' for real mosaic, otherwise 'model'
data.subject = '20076';
data.center_cone_index = 384;
% pixels per degree of the raster field; get from AOSLO calibration video
data.scaling = 550;
% standard deviation for delivery, in arcmin (average from manuscript v6)
data.delivery_error = 0.16; 
% in arcmin (aka "trial blur")
data.intratrial_delivery_error = 0.0; 
% set the defocus levels to iterate over.
defocus_levels = 0:0.025:0.15;
% eccentricity of tested retinal patch in degrees;
data.test_ecc = 1.5;
% shape of stimulus (hard-coded or read in from psy file)
data.stimshape = 'square';
data.stimsize = 3; % pixels
% in pixels; should correspond to number of pixels in AOSLO raster
data.imsize = 512; 
% in mm; coded here, or read in from CFG or .psy file (i.e. pupil_size = CFG.pupilsize)
data.pupil_size = 5.0;
% stimulus wavelength in microns
data.lamda = 543/1000;
% number of jittered deliveries per defocus level    
data.numSim = 10;
% random number generator seed
data.seed = 8484615;
% change this flag to 0 if you want to read in actual zernike files
% from HSWS (not used in this code)
data.diff_limited = 1; 
% trial intensity
data.trialIntensity = 1;
% inferred cone aperature: proportion of inner segment diameter 
% this sets the full-width-half-max of 2D Gaussian representing each cone
% From MacLeod, Williams, Mackous 1992
data.proportion = 0.48; 
% -----------------------------------------------------------------------

% --- Set the random number generator seed.
rng(data.seed);

% --- Setup saving dir and name
savename = gen_save_dir_name(data, 'dat');

% --- Generate stimulus used for testing 
stim_im_orig = gen_stimulus(data);

% --- Generate cone array
[xi, yi, model_im, model_im_layers] = gen_cone_array(data);

% --- Get delivery locations
% Place convolved stimulus at each delivered location and calculate
% light capture in each cone;
[xloc, yloc] = gen_delivery_locations(xi(1), yi(1), data);

% ---- Generate PSF
% set up PSF parameters
field_size = data.imsize ./ data.scaling; %in degrees

%typically equal
psf_pupil = data.pupil_size; 
zernike_pupil = psf_pupil;
% ---------------------- %

%half the size of the cropped stimulus representation
halfwidth = 25; 
index = 1;

% set up data structures
ndefocus = length(defocus_levels);
data.def = zeros(ndefocus, 1);
data.per_trial_int = zeros(ndefocus, data.numSim);
data.per_cone_int = zeros(ndefocus, data.numSim, size(model_im_layers, 3));
data.stim_int = zeros(ndefocus, 1);
data.stim_orig = sum(stim_im_orig(:));

if runSim == 1;
    % defocus in diopters; can vary this (or simulate random fluctuations)
    % to change the PSF and, subsequently, the convolved stimulus 
    % representation used to calculate light capture
    for defocus = defocus_levels
        % regenerate the PSF each iteration with new defocus level
        PSF = GeneratePSF(data.imsize, psf_pupil, zernike_pupil, ...
                            field_size * 60, data.lamda, data.diff_limited,...
                            defocus);
                        
        % compute the retinal image
        retina_image = gen_retina_image(stim_im_orig, PSF, halfwidth);
        
        % do the light capture calculation
        [per_trial_int, per_cone_int] = compute_light_capture(retina_image, ...
            xloc, yloc, model_im_layers, model_im, halfwidth);
        
        % store the results
        data.def(index) = defocus;
        data.per_trial_int(index, :) = per_trial_int;
        data.per_cone_int(index, :, :) = per_cone_int;
        data.stim_int(index) = sum(retina_image(:));
        
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
plotsavename = gen_save_dir_name(data, 'img');
plot_mosaic(model_im, xloc, yloc, xi, yi, halfwidth, plotsavename);

% plot the light capture analysis results
plot_light_capture(data, plotsavename);

