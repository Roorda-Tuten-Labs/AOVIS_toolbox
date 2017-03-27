function hues = arcsine_transform(data, data_format)
    % hues = arcsine_transform(vector)
    %
    % hues = total .* ((2 .* (asin((vector ./ total) .^ 0.5))) ./ pi);
    if nargin < 2
        data_format = 'button';
    end
    
    % if data are passed in as button presses, we need to do histcounts on
    % the input
    if strcmpi(data_format(1:6), 'button')
        % Split Matrix Into Cells By Row
        xc = mat2cell(data, ones(1,size(data,1)), size(data,2));  
        % Do ?histcounts? On Each Column
        [hcell, ~] = cellfun(@(x) histcounts(x, 0.5:1:5.5), xc, 'Uni', 0);
        % Recover Numeric Matrix From Cell Array
        counts = cell2mat(hcell);
    else
        counts = data;
    end
    
    % number of hue scaling button presses
    total = sum(counts(1, :));
    % apply arcsine
    hues = total .* ((2 .* (asin((counts ./ total) .^ 0.5))) ./ pi);

end