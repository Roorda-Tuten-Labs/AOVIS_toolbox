% AOSLO wavelengths (NOV 2016)
WVFRONT = 940;
IR= 840;  
RED= 680;
GREEN= 543;

base_l = IR; % set your emmetropic wavelength
lambda = GREEN; % target wavelength

% Equation 5 from Atchison, D. A., & Smith, G. (2005). 
% Chromatic dispersions of the ocular media of human eyes. JOSA A 22(1), 29-37.
R_base = 1.60911 - 6.70941*10^5/base_l^2 + 5.55334 * 10^10/base_l^4 - 5.59998*10^15/base_l^6;
R_lambda = 1.60911 - 6.70941*10^5/lambda^2 + 5.55334 * 10^10/lambda^4 - 5.59998*10^15/lambda^6;

% difference of refraction in diopters
R = R_base-R_lambda 

% Model eye power (D)
D_modeleye = 10; 

% Relative retinal position for model eye in mm
Df_modeleye = 1000 *  (1/D_modeleye - 1/(D_modeleye+R))

