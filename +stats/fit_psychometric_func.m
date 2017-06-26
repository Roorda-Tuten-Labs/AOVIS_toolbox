function pBest = fit_psychometric_func(results, ...
    pInit, color)
    
    if nargin < 3
        color = 'k';
    end
        
    %f = lsqnonlin('sigdet.fitPsychometricFunction',        
    [pBest, logLikelihoodBest] = fit_fmin('fitPsychometricFunction',...
        pInit, {'b','t'}, results, 'normcdf');

    util.pprint(logLikelihoodBest, 3, 'log-likelihood:');

    pS.MarkerFaceColor=color;
    pS.MargerEdgeColor=color;
    pS.ErrorBarColor= color;
    % curve fit color
    pS.LineColor=color; 
    % controls size
    pS.MarkerSize=4; 
    % whether the marker scales with the number of data points
    pS.MarkerScale=0; 
    
    plotPsycho(results, 'normcdf', pBest, 0, pS);
    
