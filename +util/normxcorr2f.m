function xcorr = normxcorr2f(ir_cross, currentframe)

    if exist('normxcorr2_mex') > 0
        xcorr = normxcorr2_mex(ir_cross, currentframe, 'same');
    else
        import util.normxcorr2e
        xcorr = normxcorr2e(ir_cross, currentframe, 'same');
    end
end
