function stats = corr_regress(x, y, add_plot, disp_name, print_results, ...
    corr_type) 
%   stats = corr_regress(x, y, add_plot, disp_name, print_results, ...
%        corr_type) 
    if nargin < 3
        add_plot = false;
    end
    if nargin < 4
        disp_name = ' ';
    end
    if nargin < 5
        print_results = 1;
    end
    if nargin < 6
        corr_type = 'Pearson';
    end
    import util.pprint
    
    % check that x and y do not contain any nan values. if they do the corr
    % will return nan so throw an error here to for the user to fix their
    % input
    if any(isnan(x))
        error('x vector contains NaN values');
    end
    if any(isnan(y))
        error('y vector contains NaN values');
    end
    disp(' ')
    disp('+++++++++++++++++')
    disp(['Correlation type: ' corr_type]);
    if length(x) ~= length(y)
        error('x and y must be same length');
    end
    if size(x, 1) == 1 && size(x, 2) ~= 1
        % rotate x so that it is a column vector(s)
        x = x';
    end
    if size(y, 1) == 1 && size(y, 2) ~= 1
        % rotate x so that it is a column vector(s)
        y = y';
    end    
    
    Nsamples = length(x);
    
    if ~strcmpi(corr_type, 'spearman')
        % compute regression statistics: p-value
        stats = regstats(y, x, 'linear', ...
            {'rsquare' 'fstat' 'tstat' 'beta' 'yhat' 'r'});
    end
    multiple_reg = 0;
    % compute corr coeff: need to retain sign of R.
    if size(x, 1) == 1 || size(x, 2) == 1
        [r, pval] = corr([x y], 'type', corr_type); 
        r = r(1, 2); % off diagonal.
        pval = pval(1, 2);
        stats.rval = r;
        stats.pval = pval;
    else
        % when running multiple regression (sign doesnt matter b/c not
        % plotting).
        multiple_reg = 1;
        r = sqrt(stats.rsquare);
        stats.pval = stats.fstat.pval;
    end
       
    % print out results
    if print_results        
        disp(disp_name);
        disp('+++++++++++++++++')
        disp('-- Correlation --')
        pprint(Nsamples, 0, 'N:');
        pprint(r ^ 2, 4, 'R^2:');
        pprint(r, 4, 'R:');
        
        % p-value
        
        % 95% confidence intervals for correlation
        % Formulas taken from Altman & Gardner 1988. Calculating confidence
        % intervals for regression and correlation
        % This formula is valid for both pearson and spearman.
        
        % first transform r value into a Z-score
        z_score = 0.5 * log((1 + r) / (1 - r));
        
        CIplus = z_score + (1.96 / sqrt(Nsamples - 3));
        CIminus = z_score - (1.96 / sqrt(Nsamples - 3));
        
        % convert back to original coordinates
        CIplus = (exp(2 * CIplus) - 1) / (exp(2 * CIplus) + 1);
        CIminus = (exp(2 * CIminus) - 1) / (exp(2 * CIminus) + 1);
        
        disp(['95% CI: ' num2str(round(CIminus, 2)) ' to ' ...
            num2str(round(CIplus, 2))]);
        
        if strcmpi(corr_type, 'pearson')
            % compute the stand_err. stats.r are the residuals. Take the sum of
            % residuals / N-2 and take the square root of that. This is equivalent
            % to sqrt(stats.mse).
            stand_err = sqrt(sum(stats.r .^ 2) / (length(stats.r) - 2));
            stats.stand_err = stand_err;
            pprint(stand_err, 4, 'SE:');
        
            disp(' ');
            disp('-- Regression --');
            disp(' ');
            % Regression line slope and intercept           
            pprint(stats.beta(2), 3, 'slope:');
            pprint(stats.beta(1), 3, 'inter:'); 
            disp(' ')
            
            disp('-- F-Test --');
            pprint(stats.fstat.f, 3, 'F-val:');
            pprint(stats.fstat.dfe, 3, 'dfe:');
            pprint(stats.fstat.dfr, 3, 'dfr:');

        end
        % also print p-val for spearman or multiple-regression
        pprint(stats.pval, 5, 'pval:');
        
        if multiple_reg
            disp(' ');
            disp('-- posthoc T-Tests --');
            pprint(stats.tstat.t, 3, 't-val(s):');
            pprint(stats.tstat.se, 3, 'se(s):');
            pprint(stats.tstat.pval, 3, 'p-val(s):');            
        end

        disp(' ');        
    end
    
    % Add to the current plot if flag thrown and 1D regression.
    % eventually could add 3D (2 predictors) option:
    % http://www.mathworks.com/help/stats/regress.html
    if add_plot && length(y(1, :)) == 1 && strcmpi(corr_type, 'pearson')
        % Overplot regression line, adding means back in.
        yfit = stats.beta(2) * unique(x) + stats.beta(1);
        
        plot(unique(x), yfit,'k-', 'linewidth', 2.5)
        
        regression_line_ci(0.05, stats.beta, x, y);

    end    


    function [top_int, bot_int, X] = regression_line_ci(alpha,beta,x,y,varargin)
    % [TOP_INT, BOT_INT] = REGRESSION_LINE_CI(ALPHA,BETA,X,Y)
    %
    % creates two curves marking the 1 - ALPHA confidence interval for the
    % regression line, given BETA coefficience (BETA(1) = intercept, BETA(2) =
    % slope). This is the format of STATS.beta when using 
    % STATS = REGSTATS(Y,X,'linear','beta');
    %
    % [TOP_INT, BOT_INT] = REGRESSION_LINE_CI(ALPHA,BETA,X,Y,N_PTS) defines the
    % number of points at which the funnel plot is defined. Default = 100
    %
    % [TOP_INT, BOT_INT] = REGRESSION_LINE_CI(ALPHA,BETA,X,Y,N_PTS,XMIN,XMAX)
    % defines the range of x values over which the funnel plot is defined
    %
    % https://www.mathworks.com/matlabcentral/fileexchange/39339-linear-...
    % regression-confidence-interval/content/regression_line_ci.m
    N = length(x);

    if(length(x) ~= length(y))
        error(message('regression_line_ci:x and y size mismatch')); 
    end

    x_min = min(x);
    x_max = max(x);
    n_pts = 100;

    if(nargin > 4)
        n_pts = varargin{1};
    end
    if(nargin > 6)
        x_min = varargin{2};
        x_max = varargin{3};
    end

    X = x_min:(x_max-x_min)/n_pts:x_max;
    Y = ones(size(X))*beta(1) + beta(2)*X;

    SE_y_cond_x = sum((y - beta(1)*ones(size(y))-beta(2)*x).^2)/(N-2);
    SSX = (N-1)*var(x);
    SE_Y = SE_y_cond_x*(ones(size(X))*(1/N + (mean(x)^2)/SSX) + ...
        (X.^2 - 2*mean(x)*X)/SSX);

    Yoff = (2*finv(1-alpha,2,N-2)*SE_Y).^0.5;

    % SE_b0 = SE_y_cond_x*sum(x.^2)/(N*SSX)
    % sqrt(SE_b0)

    top_int = Y + Yoff;
    bot_int = Y - Yoff;

    plot(X,top_int,'k--','LineWidth',2);
    plot(X,bot_int,'k--','LineWidth',2);
    end

end
