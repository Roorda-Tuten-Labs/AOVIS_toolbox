function [lms, wavelengths] = get_fundamentals(fund_type, resolution, ...
    min_max_wvlen, in_quanta)
% Get cone fundmentals. 
%
% USAGE
% [lms, wavelengths] = get_fundamentals(fund_type, resolution, min_max_wvlen, 
%                                        in_quanta)
%                                                      
% INPUT
% fund_type     source of fundamentals. Options = [stockman2, stockman10,
%               konig, neitz]
% resolution    sampling. If resolution of measurements is lower
%               than desired resolution, cubic spline interpolation is used 
%               to upsample to the desired resolution. Default is 1 nm.
% min_max_wvlen minimum and maximum wavelength to return. Default
%               is 400 and 750 nm.
% in_quant      return sensitivity functions in quanta. Default is
%               false, i.e. functions are in energy.
%
% OUTPUT 
% CMFs, wavelengths

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

if strcmpi(fund_type, 'stockman2') || strcmpi(fund_type, 'stockman')
    fname = 'ss2_10e_5';
    [lms, wavelengths] = load_fundamentals(fname, resolution, ...
                                                   min_max_wvlen);

elseif strcmpi(fund_type, 'stockman10')
    fname = 'ss10e_5';
    [lms, wavelengths] = load_fundamentals(fname, resolution, ...
                                                   min_max_wvlen);

elseif strcmpi(fund_type, 'konig')
    [lms, wavelengths] = konig_fundamentals(resolution, min_max_wvlen);

elseif strcmpi(fund_type, 'neitz')
    res = abs(diff(min_max_wvlen)) / resolution;
    S_sens = neitz(420, 0.0, 'alog', min_max_wvlen(1), min_max_wvlen(2), ...
                   res);
    M_sens = neitz(530, 0.0, 'alog', min_max_wvlen(1), min_max_wvlen(2), ...
                   res);
    L_sens = neitz(559, 0.0, 'alog', min_max_wvlen(1), min_max_wvlen(2), ...
                   res);
    
    wavelengths = min_max_wvlen(1):resolution:min_max_wvlen(2)';
    
    % convert to energy: make into function
    if ~in_quanta
       L_sens = L_sens .* wavelengths;       
       L_sens = L_sens ./ max(L_sens);
       M_sens = M_sens .* wavelengths;
       M_sens = M_sens ./ max(M_sens);
       S_sens = S_sens .* wavelengths;
       S_sens = S_sens ./ max(S_sens);       
    end
    lms = [L_sens; M_sens; S_sens]';
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
    fdir = fileparts(which('colorimetry.get_fundamentals'));
    fname = fullfile(fdir, 'dat', 'fundamentals', [fname '.csv']);
    fhandle = fopen(fname);
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


end