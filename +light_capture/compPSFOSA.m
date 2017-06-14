function [PSF] = compPSFOSA(c)

global PARAMS;
% Zphase_Mahajan generates the complex pupil function for the Fourier transform

pupilfunc = Zphase_MahajanOSA(c);

pupilfunc=transpose(pupilfunc);

% The amplitude of the point spread function is the Fourier transform
% of the wavefront aberration (when is it expressed in terms of phase)
Hamp=fft2(pupilfunc);

% The intensity of the PSF is the square of the amplitude
% the complex conjugate is a way of multiplying out the complex part of the function

Hint=(Hamp .* conj(Hamp));

% Define the size of the PSF plot in arcmin.
% NOTE: The dimension of a single pixel in the PSF in radians is the wavelength
% divided by the size of the pupil field.
%plotdimension = 60*PARAMS(1)*(180*60/3.1416)*PARAMS(5)*.001/PARAMS(4);

%fprintf('The size of the point spread image is %g seconds of arc\n',plotdimension);

PSF = real(fftshift(Hint)); % this comment reorients the PSF so the origin is at the center of the image
PSF = PSF./(PARAMS(6)^2); % scale the PSF so that peak represents the Strehl ratio
clear Hint;

end

