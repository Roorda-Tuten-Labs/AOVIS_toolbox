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
    
    disp(['Correlation type: ' corr_type]);
    if length(x) ~= length(y)
        error('x and y must be same length');
    end
    
    Nsamples = length(x);
    
    if ~strcmpi(corr_type, 'spearman')
        % compute regression statistics: p-value
        stats = regstats(y, x, 'linear', {'rsquare' 'fstat' 'beta' 'yhat' 'r'});
    end
    
    % compute corr coeff: need to retain sign of R.
    if length(x(1, :)) == 1
        [r, pval] = corr([x y], 'type', corr_type); 
        r = r(1, 2); % off diagonal.
        pval = pval(1, 2);
        stats.rval = r;
        stats.pval = pval;
    else
        % when running multiple regression (sign doesnt matter b/c not
        % plotting).
        r = sqrt(stats.rsquare);
    end
       
    % print out results
    if print_results
        disp(disp_name);
        pprint(Nsamples, 0, 'N:');
        pprint(r, 4, 'R:');
        
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
            
            % compute mean, stand dev and slope for regression
            xbar = mean(x);
            ybar = mean(y);
            sigx = std(x);
            sigy = std(y);

            % Regression line slope
            stats.slope = r * sigy / sigx;
            pprint(stats.slope, 4, 'slope:');
        end
        
        pprint(r ^ 2, 4, 'R^2:');
        
        % p-value
        pprint(pval, 5, 'p-val:');
        
    end
    
    % Add to the current plot if flag thrown and 1D regression.
    % eventually could add 3D (2 predictors) option:
    % http://www.mathworks.com/help/stats/regress.html
    if add_plot && length(y(1, :)) == 1 && strcmpi(corr_type, 'pearson')
        % Overplot regression line, adding means back in.
        yfit = ybar + stats.slope * (unique(x) - xbar);
        
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
