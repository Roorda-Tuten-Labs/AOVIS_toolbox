function test_chi_square

    import stats.chi_square_test

    data = [1 2 7; 4 4 3]';
    
    [pval, chi, DoF, SE] = stats.chi_square_test(data, 1, 1, [], -1);
    if round(chi, 4) ~= 1.9186
        error('chi stat not computed correctly.'); 
    end
    if round(pval, 2) ~= 0.38
        error('pval not computed correctly according to resample method.');
    end
        
    [pval, chi, DoF, SE] = stats.chi_square_test(data, 1, 1, [], 100000);
    if round(chi, 4) ~= 1.9186
        error('chi stat not computed correctly.'); 
    end
    if round(pval, 2) ~= 0.17 % 0.22 if data is not transposed.
        error('pval not computed correctly according to resample method.');
    end

    [pval, chi, DoF, SE] = stats.chi_square_test(data', 1, 1, [], 100000);
    if round(chi, 4) ~= 1.9186
        error('chi stat not computed correctly.'); 
    end
    if round(pval, 2) ~= 0.22 % 0.22 if data is not transposed.
        error('pval not computed correctly according to resample method.');
    end
    
    disp('chi_square_test: 3 out of 3 tests passed');
    
end