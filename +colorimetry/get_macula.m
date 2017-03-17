function [lms, wavelengths] = get_macula(macula_type, resolution, ...
                                                          min_maxwvlen)

% Get macula pigment optical density functions. 
%
% resolution = sampling. If resolution of measurements is lower
% than desired resolution, cubic spline interpolation is used to
% upsample to the desired resolution. Default is 1 nm.
% min_max_wvlen = minimum and maximum wavelength to return. Default
% is 400 and 750 nm.
%
% returns: lens density, wavelengths

if nargin < 1
    macula_type = 'CIE1931';
end
if nargin < 2
    resolution = 1;
end
if nargin < 3
    min_max_wvlen = [400 750];
end
