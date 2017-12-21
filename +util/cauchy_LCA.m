function cauchy_LCA(D_modeleye, ref_wvlen, target_wvlen, formula)
    % Compute the relative LCA between two wavelengths and the distance a
    % retina needs to be moved in a model eye with a given power.
    %
    % USAGE
    % cauchy_LCA(D_modeleye, ref_wvlen, target_wvlen, formula)
    %
    % D_modeleye    Model eye power (D).
    % ref_wvlen     wavelength (nm) of reference light. Default 840 nm.
    % target_wvlen  wavelength (nm) of target light. Default 543 nm.
    % formula       atchison or thibos. See Notes
    %
    % NOTES
    % Equation 5a from Atchison, D. A., & Smith, G. (2005). 
    % Chromatic dispersions of the ocular media of human eyes. 
    % JOSA A 22(1), 29-37.
    %
    % Formula from Thibos et al. 1992. (as reported in 
    % Atchison & Smith 2005; Eq 5b).

    if nargin < 1    
        D_modeleye = 10; 
    end
    if nargin < 2 || isempty(ref_wvlen)
        ref_wvlen = 840;
    end
    if nargin < 3 || isempty(target_wvlen)
        target_wvlen = 543;
    end
    if nargin < 4
        formula = 'atchison';
    end

    if strcmpi(formula, 'atchison') || strcmpi(formula, 'smith') || ...
            strcmpi(formula, 'a&s')
        R_base = atchison_smith(ref_wvlen);
        R_lambda = atchison_smith(target_wvlen);
    elseif strcmpi(formula, 'thibos')
        R_base = thibos_formula(ref_wvlen);
        R_lambda = thibos_formula(target_wvlen);
    end

    % difference of refraction in diopters
    R = R_base - R_lambda;

    % Relative retinal position for model eye in mm
    Df_modeleye = 1000 *  (1 / (D_modeleye - R) - 1 / D_modeleye);

    % Print out results
    disp(' ')
    disp(['LCA computed according to the formula of: ' formula]);
    util.pprint(ref_wvlen, 0, 'reference wavelength (nm)');
    util.pprint(target_wvlen, 0, 'target wavelength (nm)  ');
    util.pprint(R, 4, 'difference in refraction (D)')
    util.pprint(Df_modeleye, 4, 'relative retinal position (mm)')

    % subfunctions
    function D = atchison_smith(wvlen)
        D = 1.60911 - 6.70941 * 10 ^ 5 / wvlen ^ 2 + 5.55334 * ...
            10 ^ 10 / wvlen ^ 4 - 5.59998 * 10 ^ 15 / wvlen ^ 6;
    end
    function D = thibos_formula(wvlen)
        D = 1.68524 - 633.46 / (wvlen - 214.102);
    end

end