function [kappa, p_val] = cohens_kappa(X, print_results)
    % modified from http://tpingel.org/code/cohenskappa/cohenskappa.m
    if nargin < 1
        disp('Using Cohen''s test set, Table 2.b, page 45 from: Cohen, J. (1960).');
        disp('A Coefficient of Agreement for Nominal Scales. Educational and ');
        disp('Psychological Measurement, 20(1), 37-46.'); 
        X = [88 14 18; 10 40 10; 2 6 12];
        disp(X);
        print_results = 1; % ensure that results are printed.
    end
    if nargin < 2
        print_results = 1;
    end

    N = sum(X(:));
    
    % Recast X as proportions
    X = X ./ sum(X(:));

    % Observed Agreement
    PRo = sum(diag(X)) / sum(X(:));

    % Expected Agreement
    PRe = sum(sum(X,1) .* sum(X,2)');

    kappa = (PRo - PRe) / (1 - PRe);

    % now compute the std, z-score and p-val according to Cohen 1960.
    sigma = sqrt(PRe / (N * (1 - PRe)));
    z = kappa / sigma;
    p_val = 1 - normcdf(z);

    if print_results
        disp(['kappa = ',num2str(kappa, '% 4.3f')]);
        disp(['z-score = ',num2str(z, '% 4.3f')]);        
        disp(['p-val = ',num2str(p_val, '% 4.6f')]);
    end

end