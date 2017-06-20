function data = check_params(params)
%

data = params;

% --- General parameters
% subject: use '10001' or '20076' for real mosaic, otherwise 'model'
if ~isfield(data, 'subject')
    data.subject = 'model';
    disp(['setting data.subject to ' data.subject]);
end
% --- get list of stimulated cones
if ~isfield(data, 'stim_cone_IDs')
    % random index to use. only relevant if subject is a real person (not a
    % model mosaic).
    data.center_cone_index = 300;
end

% pixels per degree of the raster field; get from AOSLO calibration video
if ~isfield(data, 'scaling')
    data.scaling = 550;
    disp(['setting data.scaling to ' data.scaling]);
end
% standard deviation for delivery, in arcmin (average from manuscript v6)
if ~isfield(data, 'delivery_error')  && ~isfield(data, 'delivery_locs')
    % irrelevant if delivery_locs is present
    data.delivery_error = 0.17;
    disp(['setting data.delivery_error to ' data.delivery_error]);
    
end
% in arcmin (aka "trial blur")
if ~isfield(data, 'intratrial_delivery_error')
    data.intratrial_delivery_error = 0.0; 
    disp(['setting data.delivery_error to ' data.intratrial_delivery_error]);
end
% set defocus level in Diopters
if ~isfield(data, 'defocus')
    data.defocus = 0.0;
    disp(['setting data.defocus to ' data.defocus]);
end
% eccentricity of tested retinal patch in degrees;
if ~isfield(data, 'test_ecc')
    data.test_ecc = 1.5;
    disp(['setting data.test_ecc to ' data.test_ecc]);
    
end
% shape of stimulus (hard-coded or read in from psy file)
if ~isfield(data, 'stimshape')
    data.stimshape = 'square';
    disp(['setting data.stimshape to ' data.stimshape]);
end
% pixels
if ~isfield(data, 'stimsize')
    data.stimsize = 3; 
    disp(['setting data.stimsize to ' data.stimsize]);    
end
% in pixels; should correspond to number of pixels in AOSLO raster
if ~isfield(data, 'imsize')
    data.imsize = 512; 
    disp(['setting data.imsize to ' data.imsize]);    
end
% in mm; coded here, or read in from CFG or .psy file (i.e. pupil_size = 
% CFG.pupilsize)
if ~isfield(data, 'pupil_size')
    data.pupil_size = 6.5;
    disp(['setting data.pupil_size to ' data.pupil_size]);    
end
% number of jittered deliveries per defocus level    
if ~isfield(data, 'numSim') && ~isfield(data, 'delivery_locs')
    data.numSim = 20;
    disp(['setting data.numSim to ' data.numSim]);  
elseif isfield(data, 'delivery_locs')
    data.numSim = size(data.delivery_locs, 1);
end
% stimulus wavelength in microns
if ~isfield(data, 'lambda')
    data.lambda = 543/1000;
    disp(['setting data.lambda to ' data.lambda]);    
end
% random number generator seed
if ~isfield(data, 'seed')
    data.seed = 8484615;
    disp(['setting data.seed to ' data.seed]);    
end
% change this flag to 0 if you want to read in actual zernike files
% from HSWS (not used in this code)
if ~isfield(data, 'diff_limited')
    data.diff_limited = 1; 
    disp(['setting data.diff_limited to ' data.diff_limited]);    
end
% half the size of the cropped stimulus representation (to speed up
% computation).
if ~isfield(data, 'halfwidth')
    data.halfwidth = 25; 
end

% trial intensity
if ~isfield(data, 'trialIntensity')
    data.trialIntensity = 1;
    disp(['setting data.trialIntensity to ' data.trialIntensity]);    
end
% inferred cone aperature: proportion of inner segment diameter 
% this sets the full-width-half-max of 2D Gaussian representing each cone
% From MacLeod, Williams, Mackous 1992
if ~isfield(data, 'proportion')
    data.proportion = 0.48; 
    disp(['setting data.proportion to ' data.proportion]);    
end
% -----------------------------------------------------------------------