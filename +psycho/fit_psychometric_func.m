function [pBest, logLikelihoodBest, handle] = fit_psychometric_func(results, ...
    pInit, color, add_to_plot, print_log_like, function_to_fit)
    %
    % USAGE
    % pBest = fit_psychometric_func(results, pInit, color)
    %
    %
    
    if nargin < 3
        color = 'k';
    end
    if nargin < 4 || isempty(print_log_like)
        add_to_plot = 1;
    end
    if nargin < 5 || isempty(print_log_like)
        print_log_like = 1;
    end
    if nargin < 6
        function_to_fit = 'normcdf';
    end
        
    %f = lsqnonlin('sigdet.fitPsychometricFunction',
    if strcmpi(function_to_fit, 'normcdf')
        [pBest, logLikelihoodBest] = fit_fmin('fitPsychometricFunction',...
            pInit, {'b','t'}, results, 'normcdf');
    elseif strcmpi(function_to_fit, 'weibull')
        if ~isfield(pInit, 'g')
            pInit.g = 0.03;
        end
        if ~isfield(pInit, 'e')
            pInit.e = 0.5;
        end        
        if ~isfield(pInit, 'b')
            pInit.b = 4;
        end
        if ~isfield(pInit, 't')
            pInit.t = 0.3;
        end
       [pBest, logLikelihoodBest] = fit_fmin('fitPsychometricFunction',...
            pInit, {'b','t'}, results, 'weibull');        
    end


    if print_log_like
        util.pprint(logLikelihoodBest, 3, 'log-likelihood:');
    end

    pS.MarkerFaceColor=color;
    pS.MargerEdgeColor=color;
    pS.ErrorBarColor= color;
    % curve fit color
    pS.LineColor=color; 
    % controls size
    pS.MarkerSize=4; 
    % whether the marker scales with the number of data points
    pS.MarkerScale=0; 
    
    if add_to_plot
        logflag = 0;
        handle = plotPsycho(results, function_to_fit, pBest, logflag, pS);
    end
    
