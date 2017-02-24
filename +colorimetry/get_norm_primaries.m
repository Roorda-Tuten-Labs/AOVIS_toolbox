function primaries = get_norm_primaries(primaries)
% primaries = get_norm_primaries(primaries_name)
%
%

filedir = fileparts(which('colorimetry.get_norm_primaries'));
basename = [filedir filesep 'dat' filesep 'primaries' filesep];
if nargin < 1
    primaries = csvread([basename 'LaCiePrimariesRGB.csv']);
end

if isstr(primaries)
    if strcmp(primaries, 'lacie')
        primaries = csvread([basename 'LaCiePrimariesRGB.csv']);
    elseif strcmp(primaries, 'roorda')
        primaries = csvread([basename 'Roorda_lab_primaries.csv']);
    elseif strcmp(primaries, 'bps')
        primaries = csvread([basename 'macbook_pro_BPS.csv']);
    else
        error('Primaries not understood');
    end
end

    maxArea = max([sum(primaries(:, 2)), sum(primaries(:,3)), ...
                   sum(primaries(:, 4))]);

for index = 2:4
    % make sure primaries do not go below 0
    indZeros = find(primaries(:, index) < 0);
    primaries(indZeros, index) = 0;
    
    % normalize to sum to 1.
    primaries(:, index) = primaries(:, index) ./ maxArea;
    %sum(primaries(:,index));

end
