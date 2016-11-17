function create_default_stim
    % create_default_stim
    %
    % Create tempStimulus directory if it does not exist or delete existing
    % files in the directory if it does already exist. Then save a blank
    % 10x10 increment stimulus.
    %
    
    % blank 10x10 stimulus
    blank=ones(10, 10);
    
    if isdir(fullfile(pwd, 'tempStimulus')) == 0;
        mkdir(fullfile(pwd, 'tempStimulus'));
        imwrite(blank, fullfile(pwd, 'tempStimulus', 'frame2.bmp'));
        
    else
        % delete any existing bmp files
        delete(fullfile(pwd, 'tempStimulus', '*.*'));
        imwrite(blank, 'frame2.bmp');
    end
    
end
