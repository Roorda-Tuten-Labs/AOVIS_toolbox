function [p, chi2stat, DoF, total] = chi_square_test(observed, correction, ...
    print, DoF)
    % Chi-square test 
    %
    % 
    if nargin < 2
        correction = 0;
    end
        % correct for continuity: 
        % https://en.wikipedia.org/wiki/Yates%27s_correction_for_continuity
    if nargin < 3
        print = 0;
    end
    
    Ncols = size(observed, 2);
    Nrows = size(observed, 1);
    
    col_sums = sum(observed, 1);
    row_sums = sum(observed, 2);
    total = sum(col_sums);
    
    % sanity check
    if total ~= sum(row_sums)
        error('row sums do not equal column sums');
    end
    
    expected = zeros(size(observed));
    
    for row = 1:Nrows
        for col = 1:Ncols
            expected(row, col) = col_sums(col) * row_sums(row) / total;
        end
    end

    % Compute Chi-square statistic
    if correction
        chi2stat = sum(sum((abs(observed - expected) - 0.5) .^2 ./ expected));
    else
        chi2stat = sum(sum((observed - expected) .^2 ./ expected));
    end
    
    if nargin < 4 % compute from data
        % DoF = (rows - 1) * (columns - 1)
        DoF = (Nrows - 1) * (Ncols - 1);
    end

    % Find probability
    p = 1 - chi2cdf(chi2stat, DoF);

    if print
        % Print out final result
        disp(' ');
        disp(['Deg of Freedom: ' num2str(DoF)]);
        disp(['N:              ' num2str(total)]);
        disp(['chi-squared:    ' num2str(chi2stat)]);
        disp(['p-val:          ' num2str(p)]);
    end
end