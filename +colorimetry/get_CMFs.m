function [CMFs, wavelengths] = get_CMFs(CMF_type, resolution, ...
                                                  min_max_wvlen)
% Get color matching functions. Options include CIE1931, CIE10,
% JuddVos, Judd, StilesBurch2, StilesBurch10. Default = CIE 1931.
%
% resolution = sampling. If resolution of measurements is lower
% than desired resolution, cubic spline interpolation is used to
% upsample to the desired resolution. Default is 1 nm.
% min_max_wvlen = minimum and maximum wavelength to return. Default
% is 400 and 750 nm.
%
% returns: CMFs, wavelengths

if nargin < 1
    CMF_type = 'CIE1931';
end
if nargin < 2
    resolution = 1;
end
if nargin < 3
    min_max_wvlen = [400 750];
end

% Find file name associated with CMF. All files were downloaded
% from cvrl.org
if strcmp(CMF_type, 'CIE1931')
    fname = 'ciexyz31';
elseif strcmp(CMF_type, 'CIE10')
    fname = 'ciexyz64';
elseif strcmp(CMF_type, 'JuddVos')
    fname = 'ciexyzjv';
elseif strcmp(CMF_type, 'Judd')
    fname = 'ciexyzj';
elseif strcmp(CMF_type, 'StilesBurch2')
    fname = 'sbxyz2';
elseif strcmp(CMF_type, 'StilesBurch10')
    fname = 'sbxyz10w';
else
    error(['CMF version not understood. Select from CIE1931 CIE10 ' ...
           'JuddVos Judd StilesBurch2 or StilesBurch10']);
end

% Get  color matching functions
filedir = fileparts(which('colorimetry.get_CMFs'));
fname = fullfile(filedir, 'dat', 'cmf', [fname '.csv']);
cmfs = csvread(fname);
wavelengths = cmfs(:, 1);
cmfs = cmfs(:, 2:4);

% Check input values
if min_max_wvlen(1) < min(wavelengths) || min_max_wvlen(2) > ...
        max(wavelengths)
    error(['min_max_wvlen must be within bounds of measured CMFs: '...
           num2str(min(wavelengths)) ' ' num2str(max(wavelengths)) ...
                                                ' nm']);
end

%upsample cmfs with spline interpolation to res of 1 nm
upsampled_wavelengths = min_max_wvlen(1):resolution: ...
    min_max_wvlen(2);
CMFs = zeros(length(upsampled_wavelengths), 3);
CMFs(:, 1) = spline(wavelengths, cmfs(:, 1), ...
                    upsampled_wavelengths);
CMFs(:, 2) = spline(wavelengths, cmfs(:, 2), ...
                    upsampled_wavelengths);
CMFs(:, 3) = spline(wavelengths, cmfs(:, 3), ...
                    upsampled_wavelengths);

wavelengths = upsampled_wavelengths;
end
