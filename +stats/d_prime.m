function dprime = analyze_d_prime(l_angles, m_angles)
    %

    % d-prime analysis
    meanL = mean(l_angles);
    meanM = mean(m_angles);

    N_Lcones = length(l_angles);
    N_Mcones = length(m_angles);

    % Compute d' or equivalently Cohen's d. Question is how to compute the
    % pooled standard deviation. For now, let's follow Cohen's formula.
    lmSD = sqrt(((N_Lcones - 1) * var(l_angles) + ...
        (N_Mcones - 1) * var(m_angles)) / (N_Lcones + ...
        N_Mcones - 2));    

    % Below assumes equal sample sizes in computing pooled SD.
    % lmSD = sqrt(0.5 * (nanvar(hue_angles(l_index, 1)) + ...
    % nanvar(hue_angles(m_index, 1))));    

    % effect size: d prime or Cohen's d
    dprime = abs(meanL - meanM) / lmSD;
    
    util.pprint(dprime, 4, 'd-prime:')