function [media] = vanNorren(age, spectrum, field_size)

    format long;

    if nargin < 3
        field_size = 'large';
    end
    if nargin < 2
        spectrum = 380:1:780; 
    end
    if nargin < 1
        age = 32; 
    end

    if strcmp(field_size, 'large')
        dRL = 0.225;
    else % small
        dRL = 0.446;
    end

    media = ((dRL + 0.000031 * age^2) * ...
             (400 ./ spectrum).^4 + ...
             14.19 * 10.68 * exp(-((0.057 * (spectrum - 273)).^2)) + ...
             (0.998 - 0.000063 * age^2) * 2.13 * ...
             exp(-((0.029 * (spectrum - 370)).^2)) + ...
             (0.059 + 0.000186 * age^2) * 11.95 * ...
             exp(-((0.021 * (spectrum - 325)).^2)) + ...
             (0.016 + 0.000132 * age^2) * 1.43 * ...
             exp(-((0.008 * (spectrum - 325)).^2)) + 0.111);


end