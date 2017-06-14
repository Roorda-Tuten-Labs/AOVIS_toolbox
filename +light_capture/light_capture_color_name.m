clearvars;
close all; 
format compact

% --- General parameters
% get list of stimulated cones
cone_list = csvread(['dat/' data.subject '/cone_loc_index.csv']);
stim_cone_list = cone_list(:, 4);

% subject: use '10001' or '20076' for real mosaic, otherwise 'model'
data.subject = '20076';
% pixels per degree of the raster field; get from AOSLO calibration video
data.scaling = 550;
% standard deviation for delivery, in arcmin (average from manuscript v6)
data.delivery_error = 0.17; 
% in arcmin (aka "trial blur")
data.intratrial_delivery_error = 0.0; 
% set defocus level in Diopters
defocus = 0.00;
data.defocus = defocus;
% eccentricity of tested retinal patch in degrees;
data.test_ecc = 1.5;
% shape of stimulus (hard-coded or read in from psy file)
data.stimshape = 'square';
data.stimsize = 3; % pixels
% in pixels; should correspond to number of pixels in AOSLO raster
data.imsize = 512; 
% in mm; coded here, or read in from CFG or .psy file (i.e. pupil_size = CFG.pupilsize)
data.pupil_size = 7.2;
% number of jittered deliveries per defocus level    
data.numSim = 20;
% stimulus wavelength in microns
data.lamda = 543/1000;
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

% --- Generate stimulus used for testing 
stim_im_orig = gen_stimulus(data);

% ---- Generate PSF
% set up PSF parameters
field_size = data.imsize ./ data.scaling; %in degrees

% typically equal
psf_pupil = data.pupil_size; 
zernike_pupil = psf_pupil;

% regenerate the PSF each iteration with new defocus level
PSF = GeneratePSF(data.imsize, psf_pupil, zernike_pupil, ...
                    field_size * 60, data.lamda, data.diff_limited,...
                    defocus);

% half the size of the cropped stimulus representation
halfwidth = 25; 

% get retinal image
retina_image = gen_retina_image(stim_im_orig, PSF, halfwidth);

data.per_cone_int = zeros(length(stim_cone_list), data.numSim, 21);
for cone = 1:length(stim_cone_list)
    
    % get index of next stimulated cone
    data.center_cone_index = stim_cone_list(cone);
    
    % --- Generate cone array
    [xi, yi, model_im, model_im_layers] = gen_cone_array(data);

    % --- Get delivery locations
    % Place convolved stimulus at each delivered location and calculate
    % light capture in each cone;
    [xloc, yloc] = gen_delivery_locations(xi(1), yi(1), data);

    [~, stim_image] = compute_light_capture(retina_image, ...
        xloc, yloc, model_im_layers, model_im, halfwidth);

    data.per_cone_int(cone, :, :) = stim_image;    
    
    if mod(cone, 10) < 0.01
        disp(cone);
    end
end

% --- Save data for later
savename = [data.subject 'all_cones'];
save(['dat/' savename '.mat'], 'data'); 

% --- Plot output
f1 = figure; hold on;
axis square
xlabel('cone #')
ylabel('Proportion of captured light')
set(gca, 'TickDir', 'out', 'TickLength', [0.04 0.04], 'FontSize', 20);

disp(mean(mean(data.per_cone_int(:, :, 1), 2)))
disp(mean(mean(data.per_cone_int(:, :, 2), 2)))
disp(mean(mean(mean(data.per_cone_int(:, :, 2:7)))));

plot(mean(data.per_cone_int(:, :, 1), 2), 'bo');
plot(mean(data.per_cone_int(:, :, 2), 2), 'r.');
plot(mean(mean(data.per_cone_int(:, :, 2:7), 2), 3), 'ko');

ylim([0 1]);

%figure saving
print(f1,'-dpsc2', ['img/' savename 'light_cap.eps']);
