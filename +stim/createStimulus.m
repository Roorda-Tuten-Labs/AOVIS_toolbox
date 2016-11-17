function createStimulus(trialIntensity, stimsize, stimshape)
    import stim.*
    
    if strcmp(stimshape, 'square')
        stim_im = zeros(stimsize, stimsize);
        stim_im(1:end,1:end) = 1;

    elseif strcmp(stimshape, 'circle')
        xp =  -fix(stimsize / 2)  : fix(stimsize / 2);
        [x, y] = meshgrid(xp);
        stim_im = (x .^ 2 + y .^ 2) <= (round(stimsize / 2)) .^ 2; 
    end

    stim_im = stim_im .* trialIntensity;    

    %Make cross in IR channel to record stimulus location
    ir_im = stim.create_cross_img(21, 5, true);

    if isdir(fullfile(pwd, 'tempStimulus')) == 0;
        mkdir(fullfile(pwd, 'tempStimulus'));
    end

    blank_im = zeros(10, 10);
    
    imwrite(blank_im, fullfile(pwd, 'tempStimulus', 'frame2.bmp'));
    imwrite(ir_im, fullfile(pwd, 'tempStimulus', 'frame3.bmp'));
    imwrite(stim_im, fullfile(pwd, 'tempStimulus', 'frame4.bmp'));

end     