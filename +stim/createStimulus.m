function createStimulus(stimsize, stimshape, intensities, extension)
    % Create stimuli. Default will create a zero stimulus for frame2, cross
    % for frame3 and 100% increment for frame4.
    %
    % USAGE
    % createStimulus(stimsize, stimshape, powers)
    %    
    % INPUT
    % stimsize:     in pixels
    % stimshape:    char. currently supports square or circle
    % intensity:    stimulus intensity. values should be between 0
    %               and 1. powers can be a single value or an array of
    %               values, in which case a bmp file will be created for
    %               each power.
    % extension:    bmp or buf. default is bmp. bit depth is higher with
    %               buf.
    %
    % OUTPUT
    % saves bmp files into tempStimulus directory
    %
    if nargin < 3 || isempty(intensities)
        intensities = 1;
    end
    if nargin < 4
        extension = 'bmp';
    end
    
    stimdir = fullfile(pwd, 'tempStimulus');
    
    % cycle through powers and create stimuli for each
    frameN = 4;
    for p = 1:length(intensities)
        intensity = intensities(p);
        if strcmp(stimshape, 'square')
            stim_im = zeros(stimsize, stimsize);
            stim_im(1:end,1:end) = intensity;

        elseif strcmp(stimshape, 'circle')
            xp = -fix(stimsize / 2):fix(stimsize / 2);
            [x, y] = meshgrid(xp);
            stim_im = (x .^ 2 + y .^ 2) <= (round(stimsize / 2)) .^ 2;
            stim_im = stim_im .* intensity;
        end
        % write to file        
        if strcmpi(extension, 'bmp')
            imwrite(stim_im, fullfile(stimdir, ...
                ['frame' num2str(frameN) '.bmp']));
        elseif strcmpi(extension, 'buf')
            stim.write_to_buf_file(stim_im, num2str(frameN), stimdir, ...
                'frame')
        end
        frameN = frameN + 1;
    end

    if isdir(fullfile(pwd, 'tempStimulus')) == 0
        mkdir(fullfile(pwd, 'tempStimulus'));
    end
    
    % make a blank (zero value) stimulus
    blank_im = zeros(10, 10);
    % write to file        
    if strcmpi(extension, 'bmp')
        imwrite(blank_im, fullfile(stimdir, 'frame2.bmp'));
    elseif strcmpi(extension, 'buf')
        stim.write_to_buf_file(blank_im, '2', stimdir, ...
            'frame')
    end    
    
    %Make cross in IR channel to record stimulus location
    ir_im = stim.create_cross_img(21, 5, true);    
    % write to file        
    if strcmpi(extension, 'bmp')
        imwrite(ir_im, fullfile(stimdir, 'frame3.bmp'));
    elseif strcmpi(extension, 'buf')
        stim.write_to_buf_file(ir_im, '3', stimdir, ...
            'frame')
    end                    

end     