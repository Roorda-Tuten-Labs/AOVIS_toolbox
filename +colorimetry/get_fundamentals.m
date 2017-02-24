function [lms, wavelengths] = get_fundamentals(fund_type, resolution, ...
                                                          min_max_wvlen, ...
                                                          in_quanta)
% Get cone fundmentals. 
%
% fund_type = source of fundamentals.
% resolution = sampling. If resolution of measurements is lower
% than desired resolution, cubic spline interpolation is used to
% upsample to the desired resolution. Default is 1 nm.
% min_max_wvlen = minimum and maximum wavelength to return. Default
% is 400 and 750 nm.
% in_quant = return sensitivity functions in quanta. Default is
% false, i.e. functions are in energy.
%
% returns: CMFs, wavelengths

if nargin < 1
    fund_type = 'stockman2';
end
if nargin < 2
    resolution = 1;
end
if nargin < 3
    min_max_wvlen = [400 750];
end
if nargin < 4
    in_quanta = 0;
end

if strcmp(lower(fund_type), 'stockman2') || strcmp(lower(fund_type), ...
                                                   'stockman')
    fname = 'ss2_10e_5';
    [lms, wavelengths] = load_fundamentals(fname, resolution, ...
                                                   min_max_wvlen);

elseif strcmp(lower(fund_type), 'stockman10')
    fname = 'ss10e_5';
    [lms, wavelengths] = load_fundamentals(fname, resolution, ...
                                                   min_max_wvlen);

elseif strcmp(lower(fund_type), 'konig')
    [lms, wavelength] = [lms, wavelengths] = konig_fundamentals(resolution, ...
                                                      min_max_wvlen)

elseif strcmp(lower(fund_type), 'neitz')
    S_sens = neitz(420, 0.3, 'log', min_max_wvlen(1), min_max_wvlen(2), ...
                   resolution)
    M_sens = neitz(530, 0.45, 'log', min_max_wvlen(1), min_max_wvlen(2), ...
                   resolution)
    L_sens = neitz(559, 0.45, 'log', min_max_wvlen(1), min_max_wvlen(2), ...
                   resolution)

    
end

% Convert to quanta if desired
if in_quanta
    for j = 1:3
        lms(:, j) = 10 .^ lms(:, j);
        lms(:, j) = lms(:, j) ./ wavelengths';
        lms(:, j) = lms(:, j) ./ max(lms(:, j));
        lms(:, j) = log10(lms(:, j));
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% subfunctions %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lms, wavelengths] = load_fundamentals(fname, resolution, ...
                                               min_max_wvlen)

    % Get  color matching functions
    % Need to use textscan because csvread does not handle blank
    % cells properly. This is especially important here because
    % some files, eg Stockman S-cone fundamentals, have a large
    % number of empty cells. We need those to be NaN.
    fhandle = fopen(['dat/fundamentals/' fname '.csv']);
    funds = textscan(fhandle, '%f %f %f %f', 'delimiter', ',', ...
                     'emptyvalue', NaN);
    fclose(fhandle);

    % For an unknown reason textscan doesn't read last empty value
    % of S-cones so have to append an NaN
    if length(funds{4}) < length(funds{3})
        funds{4} = [funds{4}; NaN];
    end

    funds = cell2mat(funds);
    wavelengths = funds(:, 1);
    funds = funds(:, 2:4);

    % Check input values
    if min_max_wvlen(1) < min(wavelengths) || min_max_wvlen(2) > ...
            max(wavelengths)
        error(['min_max_wvlen must be within bounds of measured Lms: '...
               num2str(min(wavelengths)) ' ' num2str(max(wavelengths)) ...
                                                ' nm']);
    end

    % upsample lms with spline interpolation to res of 1 nm
    upsampled_wavelengths = min_max_wvlen(1):resolution: ...
        min_max_wvlen(2);
    lms = zeros(length(upsampled_wavelengths), 3);
    lms(:, 1) = spline(wavelengths, funds(:, 1), ...
                        upsampled_wavelengths);
    lms(:, 2) = spline(wavelengths, funds(:, 2), ...
                        upsampled_wavelengths);
    
    % need to handle Stockman cases where S-cones not reported past
    % 615 nm
    maxind = max(find(~isnan(funds(:, 3))));
    maxwv = wavelengths(maxind);
    lms(:, 3) = spline(wavelengths(1:maxind), funds(1:maxind, 3), ...
                        upsampled_wavelengths);
    % the spline fit will produce a function that starts to turn
    % upwards at the very long wavelengths. Could in some cases
    % chop these numbers off.
    %cutoff = upsampled_wavelengths > maxwv;
    %lms(cutoff, 3) = NaN;

    wavelengths = upsampled_wavelengths;
end

function [lms, wavelengths] = konig_fundamentals(resolution, min_max_wvlen)
% Get CMFs
    [CMFs, wavelengths] = get_CMFs('CIE1931', resolution, min_max_wvlen);

    % From Wyszechki & Stiles pg 606
    M = [0.0713 0.9625 -0.0147;
         -0.3952 1.1668 0.0815;
         0.0 0.0 0.5610];

    % The results of this transformation have been checked against the
    % values reported in Table 8.2.5 W & S pg 606.
    lms = M * CMFs';
    lms = lms';

end

function [withOD, extinction] = neitz(LambdaMax, OpticalDensity, Output, StartWavelength, EndWavelength, Res)
%spectsens returns a photopigment spectral sensitivity curve
%as defined by Carroll, McMahon, Neitz, and Neitz.
%[withOD, extinction curve] = spectsens(LambdaMax, OpticalDensity, OutputType, StartWavelength, EndWavelength,
%Resolution)
%
%LambdaMax = Wavelength peak for photopigment (default = 559)
%OpticalDensity = optical density required (default = 0.20)
%OutputType = log or anti-log.  if log, maximum data ouput is 0.  if
%anti-log, data output is between 0 and 1 (default = log).
%StartWavelength = beginning wavelength (default = 380)
%EndWavelength = end wavelength (default = 780)
%Resolution = Number of data points (default = 1000)


format long;

if nargin < 6, Res = 1000; end
if nargin < 5, EndWavelength = 780; end
if nargin < 4, StartWavelength = 380; end
if nargin < 3, Output = 'log'; end
if nargin < 2, OpticalDensity = 0.2000; end
if nargin < 1, LambdaMax = 559; end

A = 0.417050601;
B = 0.002072146;
C = 0.000163888;
D = -1.922880605;
E = -16.05774461;
F = 0.001575426;
G = 5.11376E-05;
H = 0.00157981;
I = 6.58428E-05;
J = 6.68402E-05;
K = 0.002310442;
L = 7.31313E-05;
M = 1.86269E-05;
N = 0.002008124;
O = 5.40717E-05;
P = 5.14736E-06;
Q = 0.001455413;
R = 4.217640000E-05;
S = 4.800000000E-06;
T = 0.001809022;
U = 3.86677000E-05;
V = 2.99000000E-05;
W = 0.001757315;
X = 1.47344000E-05;
Y = 1.51000000E-05;
Z = OpticalDensity+0.00000001;

if (EndWavelength-StartWavelength)==0
    inc = 1/Res;
else
    inc = ((EndWavelength - StartWavelength)/Res);
end

A2=(log10(1.00000000/LambdaMax)-log10(1/558.5));
vector = log10((StartWavelength:inc:EndWavelength).^-1);
const = 1/sqrt(2*pi);

exTemp=log10(-E+E*tanh(-(((10.^(vector-A2)))-F)/G))+D+A*tanh(- ...
                                                  (((10.^(vector- ...
                                                  A2)))-B)/C) - ...
       (J/I*(const*exp(1).^(-0.5*(((10.^(vector-A2))-H)/I).^2))) - ...
       (M/L*(const*exp(1).^(-0.5*(((10.^(vector-A2))-K)/L).^2))) - ...
       (P/O*(const*exp(1).^(-0.5*(((10.^(vector-A2))-N)/O).^2))) + ...
       (S/R*(const*exp(1).^(-0.5*(((10.^(vector-A2))-Q)/R).^2))) + ...
       ((V/U*(const*exp(1).^(-0.5*(((10.^(vector-A2))-T)/U).^2)))/10) ...
       + ((Y/X*(const*exp(1).^(-0.5*(((10.^(vector-A2))-W)/ ...
                                     X).^2)))/100);

ODTemp = log10((1-10.^-((10.^exTemp)*Z))/(1-10^-Z));

if (strcmp(Output, 'log') == 1)
    extinction = exTemp;
    withOD = ODTemp;
else
    extinction = 10.^(exTemp);
    withOD = 10.^(ODTemp);
end

end

end