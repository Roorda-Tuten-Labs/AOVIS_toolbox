function [pval, chi2stat, DoF, SE] = chi_square_test(observed, correction, ...
    print, DoF, Nrand)
    % Chi-square test 
    % [pval, chi2stat, DoF, SE] = chi_square_test(observed,
    % correction, print, DoF, Nrand)
    %
    % INPUT
    % observed: an n x m contingency table.
    %           correction: decide whether to apply a Yates correction for 
    %           continuity and small sample sizes. Default is 0. 
    % print:    decide whether to print out the results to the command line.
    %           Default is 0.
    % DoF:      degrees of freedom. If nothing is passed, the program will
    %           compute DoF based on the dimensions of the observed matrix
    %           according to (N rows - 1)(N cols - 1)
    % Nrand:    use if you would like to compute the p-value based
    %           on a monte carlo resampling of the data. This is also called a
    %           "Randomization test of independence". 
    %           CAUTION: This method is sensitive to the orientation of
    %           rows and columns. It will produce different p-values if the
    %           matrix is transposed.
    %           See: https://udel.edu/~mcdonald/statrandind.html
    % 
    % OUTPUT
    % pval:     p-value computed according to either a chi-square probability
    %           distribution or a randomization (monte carlo) test.
    % chi2stat: the Chi-square statistic.
    % DoF:      degrees of freedom.
    % SE:       Standard error of the Chi-square statistic computed
    %           according to the sqrt of the expected value under null hypothysis.
    %
    %
    % For more info on Chi-square see:
    % http://www.physics.csbsju.edu/stats/chi-square.html
    
    import util.*
    
    if nargin < 2 || isempty(correction)
        % correct for continuity: 
        % https://en.wikipedia.org/wiki/Yates%27s_correction_for_continuity
        correction = 0;
    end
    if nargin < 3 || isempty(print)
        print = 0;
    end 
    if nargin < 5
        Nrand = -1;
    end
    
    Ncols = size(observed, 2);
    Nrows = size(observed, 1);
    if nargin < 4  || isempty(DoF) % compute from data
        % DoF = (rows - 1) * (columns - 1)
        DoF = (Nrows - 1) * (Ncols - 1);
    end
    
    % test if matrix has zero rows or columns
    tobserved = util.remove_zero_cols(observed);
    if size(tobserved, 1) ~= size(observed, 1) 
        error('Matrix contained columns with only zeros')
    end
    tobserved = util.remove_zero_rows(observed);
    if size(tobserved, 2) ~= size(observed, 2)
        error('Matrix contained rows with only zeros')
    end

    % find the chi square statistic
    [chi2stat, expected, total] = compute_chi_stat(observed, correction);
    
    if Nrand == -1
        % Find probability with chi square distribution
        pval = 1 - chi2cdf(chi2stat, DoF);
    else
        % use a monte carlo simulation to estimate p value

        % create a mask for simulating data below
        mask = zeros(size(observed, 1), total); 
        start = 1; 
        rowsums = sum(observed, 2);
        finish = rowsums(1);
        mask(1, start:finish) = 1; 
        for ii = 2:size(observed, 1)
            start = start + rowsums(ii - 1); 
            finish = start + rowsums(ii) - 1; 
            mask(ii, start:finish) = 1; 
        end 

        % monte carlo resimulation
        chi_sims = zeros(1, Nrand); 
        for ii = 1:Nrand 
            sim_data = zeros(size(observed));
            % need to do Ncols-1 sims
            for c = 1:size(observed, 2) - 1
                S = randperm(total) <= sum(observed(:, c)); 
                ss = mask * S';
                sim_data(:, c) = ss;
            end
            % fill in last row
            sim_data(:, end) = rowsums - sum(sim_data, 2);
            % compute chi stat for simulated data
            chi_sims(ii) = compute_chi_stat(sim_data, correction);
        end         
        pval = mean(chi_sims >= chi2stat);
    end

    % Find SE
    SE = sqrt(sum(sum(expected)));
    
    if print
        % Print out final result
        disp(' ');
        disp(['Deg of Freedom: ' num2str(DoF)]);
        disp(['N:              ' num2str(total)]);
        disp(['chi-squared:    ' num2str(chi2stat)]);
        disp(['standard error: ' num2str(SE)]);
        disp(['p-val:          ' num2str(pval)]);
    end
    
    % compute the chi squared statistics
    function [chi2stat, expected, total] = compute_chi_stat(observed, correction)
        col_sums = sum(observed, 1);
        row_sums = sum(observed, 2);
        total = sum(col_sums);
    
        % sanity check
        if total ~= sum(row_sums)
            error('row sums do not equal column sums');
        end
        
        expected = zeros(size(observed));
        for row = 1:size(observed, 1)
            for col = 1:size(observed, 2)
                expected(row, col) = col_sums(col) * row_sums(row) / total;
            end
        end

        % Compute Chi-square statistic
        if correction
            chi2stat = sum(sum((abs(observed - expected) - 0.5) .^2 ./ expected));
        else
            chi2stat = sum(sum((observed - expected) .^2 ./ expected));
        end

    end
end