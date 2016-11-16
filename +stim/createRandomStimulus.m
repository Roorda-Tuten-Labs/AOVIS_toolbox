function createRandomStimulus(trialIntensity, stimsize)
    
    if isdir(fullfile(pwd, 'tempStimulus')) == 0;
        mkdir(fullfile(pwd, 'tempStimulus'));
        cd(fullfile(pwd, 'tempStimulus'));
    else
        cd(fullfile(pwd, 'tempStimulus'));
    end

    frameN = 4;
    % 5x5 grid of possible locations for stim.
    for xx = 1:stimsize:stimsize * 5
        for yy = 1:stimsize:stimsize * 5
            stim_im0 = zeros(stimsize * 5, stimsize * 5);
            % set squares to 1 intensity
            stim_im0(xx:xx + stimsize - 1, yy:yy + stimsize - 1) = 1;

            stim_im0 = stim_im0 .* trialIntensity;    
            
            imwrite(stim_im0, ['frame' num2str(frameN) '.bmp']);
            frameN = frameN + 1;
        end
    end
    
    % Make cross in IR channel to record stimulus location
    ir_im0 = stim.create_cross_img(21, 5, true);
    
    blank_im0 = zeros(10, 10);
    
    imwrite(blank_im0, 'frame2.bmp');
    imwrite(ir_im0, 'frame3.bmp');
    
    cd ..;
end  