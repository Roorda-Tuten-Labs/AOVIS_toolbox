function params = gen_default_params()
%

% --- General parameters
% subject: use '10001' or '20076' for real mosaic, otherwise 'model'
params.subject = 'model';

% pixels per degree of the raster field; get from AOSLO calibration video
params.scaling = 550;

% standard deviation for delivery, in arcmin (average from manuscript v6)
params.delivery_error = 0.17;

% in arcmin (aka "trial blur")
params.intratrial_delivery_error = 0.0; 

% set defocus level in Diopters
params.defocus = 0.0;

% eccentricity of tested retinal patch in degrees;
params.test_ecc = 1.5;

% shape of stimulus (hard-coded or read in from psy file)
params.stimshape = 'square';

% pixels
params.stimsize = 3; 

% in pixels; should correspond to number of pixels in AOSLO raster
params.imsize = 512; 

% in mm; coded here, or read in from CFG or .psy file (i.e. pupil_size = 
% CFG.pupilsize)
params.pupil_size = 6.5;

% number of jittered deliveries per defocus level    
params.numSim = 20;

% stimulus wavelength in microns
params.lambda = 543/1000;

% random number generator seed
params.seed = 8484615;

% change this flag to 0 if you want to read in actual zernike files
% from HSWS (not used in this code)
params.diff_limited = 1; 

% half the size of the cropped stimulus representation (to speed up
% computation).
params.halfwidth = 25; 

    
% trial intensity
params.trialIntensity = 1;

% inferred cone aperature: proportion of inner segment diameter 
% this sets the full-width-half-max of 2D Gaussian representing each cone
% From MacLeod, Williams, Mackous 1992

params.proportion = 0.48; 
