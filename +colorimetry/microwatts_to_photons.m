function Qtotal = microwatts_to_photons(uW, wavelength, npixel, nframes, sec_per_pxl)
% Convert microwatts to photons. This routine has been written for
% use with an AOSLO scanning laser microscope. 
%
% uW = The output of the power of the AOSLO in micro Watts measured
%   with a power meter.
% wavelength = The wavelength (nm) of the AOSLO laser that was
%   measured (default = 543 nm for green stim channel)
% npixel = number of pixels in your stimulus. For example, a 3x3 
%   square has 9 pixels. Default is 1, i.e. the output will be in
%   quanta per pixel.
% nframes = number of frames in the stimulus. Default is 1.
% sec_per_pxl = the amount of time each pixel is 'on' in the AOSLO.
%   As of Dec 2015 this value was 5 x 10^-8, but this will change
%   when the scanners are altered.
%
% Returns: Qtotal or the number of quanta over the whole stimulus
%   (taking into account npixel and nframes).
% 
% For reference see Appendix of Will Tuten's dissertation. 

if nargin < 2
    % wavelength of stim channel (nm)
    wavelength = 543;
end
if nargin < 3
    npixel = 1;
end
if nargin < 4
    nframes = 1;
end
if nargin < 5
    % sec/pixel scanning = (5x10^-8)
    sec_per_pxl = (5 * 10^-8);
end

% Convert wavelength to meters
wavelength_in_meters = wavelength * 10^-9;

% Compute Jules per quanta for lambda (543 nm)
c = 2.9979 * 10^8; % speed of light in m/s
h = 6.626070 * 10^-34; % Plancks constant in J*s
Equantum = h * c / wavelength_in_meters; %Jules/quanta

% Convert power in microWatts to Joules per second (1W = 1J/S)
power_JperSec = uW .* 10.^ -6;

% Convert to quanta per second
Qs = power_JperSec ./ Equantum;

% Compute quanta per pixel
Qp = Qs .* sec_per_pxl;

% Compute total quanta in stimulus
Qtotal = Qp * npixel * nframes;

end