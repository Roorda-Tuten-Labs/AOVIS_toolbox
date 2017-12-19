function [bestparams, chi, SE, correl_mat, h] = fit_stevens_law(x, y, ...
    params0, add_to_plot)
    %
    %
    if nargin < 3 || isempty(params0)
        params0 = [5.5 0.17 0.8];
    end
    if nargin < 4 || isempty(add_to_plot)
        add_to_plot = 0;
    end
    
    % error function: chi-square: Sum ((expected - data) / sqrt(expected))
    error_func = @(params) sum(((y - psycho.stevens_law(x, params, 1)) ...
        .^ 2) ./ sqrt(std(y)));

    % use lsqnonlin to find the best fit.
    options.Algorithm = 'levenberg-marquardt';
    options.Display = 'off';
    options.MaxFunctionEvaluations = 1500;
    [bestparams,~,~,~,~,~,jacobian] = lsqnonlin(error_func, params0, [], [], ...
        options);
    
    if add_to_plot      
        xvals = x(1):0.02:x(end);
        h = plot(xvals, psycho.stevens_law(xvals, bestparams), ...
            'k-', 'linewidth', 2);
    end    
    
    if nargout > 1
        chi = error_func(bestparams);
    end
    
    if nargout > 2
        jacobian = full(jacobian);
        cov_mat = inv(jacobian' * jacobian);
        SE = sqrt(diag(cov_mat))';
    end
    if nargout > 3
        correl_mat = cov_mat ./ (SE' * SE);
    end
    