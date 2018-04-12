function dprime = d_prime(x, y, Nresample)
    % dprime = d_prime(x, y)
    %
    % d' analysis on two distributions.
    %
    % INPUT
    % x:            distribution 1
    % y:            distribution 2
    % Nresample:    number of resamples for confidence interval bootstrap.
    %
    % OUTPUT
    % dprime
    %
        
    if nargin < 3 || isempty(Nresample)
        Nresample = 10000;
    end
    
    % make sure that x and y have no nan values
    x = x(~isnan(x));
    y = y(~isnan(y));
    
    Nx = length(x);
    Ny = length(y);

    DoF = Nx + Ny - 2;    
    
    [dprime, z_score] = compute_d(x, y);
    
    % two-tailed p value
    p_val = 1 - (normcdf(abs(z_score), 0, 1));
    
    % resample x and y distributions to get 95% CI    
    resample_dprime = zeros(Nresample, 1);
    for r = 1:Nresample
        % resample with replacement
        x_resamp = zeros(Nx, 1);
        for xx = 1:Nx
            x_resamp(xx) = x(randi(Nx));
        end
        y_resamp = zeros(Ny, 1);
        for yy = 1:Ny
            y_resamp(yy) = y(randi(Ny));
        end        
        
        resample_dprime(r) = compute_d(x_resamp, y_resamp);
    end
    
    resample_dprime = sort(resample_dprime);
    lower_CI = resample_dprime(floor(Nresample * 0.025));
    upper_CI = resample_dprime(Nresample - ceil(Nresample * 0.025));    
    
    % print the output
    util.pprint(dprime, 4, 'd-prime:')
    util.pprint(DoF, 4, 'DoF:')
    disp(['95% CI: ' num2str(lower_CI) ' - ' num2str(upper_CI)]) 
    util.pprint(p_val, 4, 'p-val:');
    
    
    function [dprime, z_score] = compute_d(x_0, y_0)
        % d-prime analysis
        meanX = mean(x_0);
        meanY = mean(y_0);
        
        Nx0 = length(x_0);
        Ny0 = length(y_0);

        DoF0 = Nx0 + Ny0 - 2;          

        % Compute d' or equivalently Cohen's d. Question is how to compute the
        % pooled standard deviation. For now, let's follow Cohen's formula.
        xySD = sqrt(((Nx0 - 1) * var(x_0) + (Ny0 - 1) * var(y_0)) / DoF0);    

        % Below assumes equal sample sizes in computing pooled SD.
        % xySD = sqrt(0.5 * (nanvar(hue_angles(l_index, 1)) + ...
        % nanvar(hue_angles(m_index, 1))));    

        % effect size: d prime or Cohen's d
        dprime = abs(meanX - meanY) / xySD;
        N = mean([Nx0 Ny0]);
        z_score = abs(meanX - meanY) / (xySD / sqrt(N));
    end
end