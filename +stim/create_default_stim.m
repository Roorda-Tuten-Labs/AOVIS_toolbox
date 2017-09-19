function create_default_stim(extension)
    % create_default_stim
    %
    % Create tempStimulus directory if it does not exist or delete existing
    % files in the directory if it does already exist. Then save a blank
    % 10x10 increment stimulus.
    %
    if nargin < 1
        extension = 'bmp';
    end
    
    % blank 10x10 stimulus
    blank=ones(10, 10);
    
    if isdir(fullfile(pwd, 'tempStimulus')) == 0
        mkdir(fullfile(pwd, 'tempStimulus'));
    else
        % delete any existing bmp files
        delete(fullfile(pwd, 'tempStimulus', '*.*'));
    end
    
    stimdir = fullfile(pwd, 'tempStimulus');
    
    if strcmpi(extension, 'bmp')
        imwrite(blank, fullfile(stimdir, 'frame2.bmp'));
    elseif strcmpi(extension, 'buf')
        stim.write_to_buf_file(blank, '2', stimdir, 'frame')
    end
    
end
