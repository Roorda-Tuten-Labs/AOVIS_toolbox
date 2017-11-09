function dprime = d_prime(x, y)
    % dprime = d_prime(x, y)
    %
    % d' analysis
    %
    % INPUT
    % x:    distribution 1
    % y:    distribution 2
    %
    % OUTPUT
    % dprime
    %

    Nresample = 10000;
    
    % make sure that x and y have no nan values
    x = x(~isnan(x));
    y = y(~isnan(y));
    
    Nx = length(x);
    Ny = length(y);

    DoF = Nx + Ny - 2;    
    
    dprime = compute_d(x, y);
    
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
    
    
    function dprime = compute_d(x_0, y_0)
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
    end
end