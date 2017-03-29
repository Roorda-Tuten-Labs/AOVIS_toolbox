function createStimulus(stimsize, stimshape, powers)
    import stim.*
    if nargin<3
        powers = 1;
    end
    % cycle through powers and create stimuli for each
    frameN = 4;
    for p = 1:length(powers)
        power = powers(p);
        if strcmp(stimshape, 'square')
            stim_im = zeros(stimsize, stimsize);
            stim_im(1:end,1:end) = power;

        elseif strcmp(stimshape, 'circle')
            xp =  -fix(stimsize / 2)  : fix(stimsize / 2);
            [x, y] = meshgrid(xp);
            stim_im = (x .^ 2 + y .^ 2) <= (round(stimsize / 2)) .^ 2; 
        end    
        imwrite(stim_im, fullfile(pwd, 'tempStimulus', ...'
            ['frame' num2str(frameN) '.bmp']));
        frameN = frameN + 1;
    end

    %Make cross in IR channel to record stimulus location
    ir_im = stim.create_cross_img(21, 5, true);

    if isdir(fullfile(pwd, 'tempStimulus')) == 0;
        mkdir(fullfile(pwd, 'tempStimulus'));
    end

    blank_im = zeros(10, 10);
    
    imwrite(blank_im, fullfile(pwd, 'tempStimulus', 'frame2.bmp'));
    imwrite(ir_im, fullfile(pwd, 'tempStimulus', 'frame3.bmp'));
    

end     