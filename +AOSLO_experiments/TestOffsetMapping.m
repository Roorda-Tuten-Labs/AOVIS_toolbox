function TestOffsetMapping
% import external library functions
import util.*
import aom.*
import stim.*

% --------------- Parameters --------------- %

% ------------------------------------------- %

% set some variable to global. most of these are first modified 
% by AOMcontrol.m
global SYSPARAMS StimParams VideoParams; %#ok<NUSED>

% get experiment config data stored in appdata for 'hAomControl'
hAomControl = getappdata(0,'hAomControl');

% This is a subroutine located at the end of this file. Generates some
% default stimuli
stim.create_default_stim();

% now wait for ui to load
CFG = AOSLO_experiments.HueScaling_CFG_gui();
CFG.videodur = 1.0;
CFG.angle = 0;

if isstruct(CFG) == 1;
    if CFG.ok == 1
        StimParams.stimpath = fullfile(pwd, 'tempStimulus', filesep);
        VideoParams.vidprefix = CFG.vidprefix;

        if CFG.record == 1;
            VideoParams.videodur = CFG.videodur;
        end

        % save the CFG file for next time
        save(fullfile('Experiments', 'lastBasicCFG.mat'), 'CFG');
        
        % sets VideoParam variables
        set_VideoParams_PsyfileName();  
        
        % Appears to load stimulus into buffer. Called here with parameter
        % set to 1. This seems to load some default settings. Later calls
        % send user defined settings via netcomm.
        Parse_Load_Buffers(1);

    else
        return;
    end
end


% get handle to aom gui
handles = aom.setup_aom_gui();

dirname = fullfile(StimParams.stimpath, filesep);
fprefix = StimParams.fprefix;
% ------------------------------------------------------------- %

% ---- Setup Mov structure ---- %
CFG.gain = 0;

Mov = aom.generate_mov(CFG);
Mov.dir = dirname;
Mov.suppress = 0;
Mov.pfx = fprefix;

% Use cross for aom0
Mov.aom0seq(Mov.aom0seq ~= 0) = 3; % 3 is index of cross.

% ---- Apply TCA offsets ---- %

tca_green = [0 0; -1 1; 1 1; -1 -1; 1 -1] .* 100;
cross_xy = [0 0];
stim_xy = [0 0];
sequence_length = length(Mov.aom2seq);

% Turn ON AOMs
SYSPARAMS.aoms_state(1)=1;
SYSPARAMS.aoms_state(2)=1; % SWITCH RED ON
SYSPARAMS.aoms_state(3)=1; % SWITCH GREEN ON


% --------------------------------------------------- %
% --------------- Begin Experiment ------------------ %
% --------------------------------------------------- %

% Set initial while loop conditions
runExperiment = 1;
trial = 1;
PresentStimulus = 1;
GetResponse = 0;
set(handles.aom_main_figure, 'KeyPressFcn','uiresume');

kb_AbortConst = 'escape';
kb_StimConst = 'space';

kb_DecrementTrial = 'return';
kb_IncrementTrial = 'shift';

kb_LeftArrow = 'leftarrow';
kb_RightArrow = 'rightarrow';
kb_UpArrow = 'uparrow';
kb_DownArrow = 'downarrow';


CFG.stimsize = 11;

% generate stimulus based on size, shape and intensity.
stim.createStimulus(1, CFG.stimsize, CFG.stimshape);

% Overwrite cross for IR channel so that is size desired here.
ir_im = stim.create_cross_img(33, 11, true);
cd(fullfile(pwd, 'tempStimulus'));
imwrite(ir_im, 'frame3.bmp');
cd ..;
    
% Start the experiment
while(runExperiment ==1)
    uiwait;
    resp = get(handles.aom_main_figure,'CurrentKey');
    disp(resp);
    
    % if abort key triggered, end experiment safely.
    if strcmp(resp, kb_AbortConst);
        runExperiment = 0;
        uiresume;
        TerminateExp;
        message = ['Off - Experiment Aborted - Trial ' num2str(trial) ' of '...
                   num2str(size(tca_green, 1))];
        set(handles.aom1_state, 'String', message);
            
    % check if present stimulus button was pressed
    elseif strcmp(resp, kb_StimConst)
        if PresentStimulus == 1 && trial <= size(tca_green, 1)
            % play sound to indicate start of stimulus
            sound(cos(90:0.75:180))

            % update system params with stim info
            if SYSPARAMS.realsystem == 1
                StimParams.stimpath = dirname;
                StimParams.fprefix = fprefix;
                StimParams.sframe = 2;
                StimParams.eframe = 4;
                StimParams.fext = 'bmp';
                Parse_Load_Buffers(0);
            end

            % ---- set movie parameters to be played by aom ---- %
            % Select AOM power
            Mov.aom2pow(:) = 1;
            Mov.aom0pow(:) = 1;

            % for testing change the TCA depending on trial number
            [aom2offx_mat, aom2offy_mat] = aom.apply_TCA_offsets_to_locs(...
                tca_green(trial, :), cross_xy, stim_xy, sequence_length);

            % tell the aom about the offset (TCA + cone location)
            Mov.aom2offx = aom2offx_mat(1, :, :);
            Mov.aom2offy = aom2offy_mat(1, :, :);
            
            % change the message displayed in status bar
            message = ['Running Experiment - Trial ' num2str(trial) ...
                       ' of ' num2str(size(tca_green, 1))];
            Mov.msg = message;
            Mov.seq = '';
            
            % send the Mov structure to app data
            setappdata(hAomControl, 'Mov', Mov);
            
            VideoParams.vidname = [CFG.vidprefix '_' sprintf('%03d', trial)];

            % use the Mov structure to play a movie
            PlayMovie;

            % update loop variables
            PresentStimulus = 0;
            GetResponse = 1;

        else
            % Repeat trial. Not sure it ever gets down here.   
            GetResponse = 1;
            % Play sound.
            sound(sin(0:0.5:90));
            PresentStimulus = 1;
            % Update message
            message1 = [Mov.msg ' Repeat trial'];
            set(handles.aom1_state, 'String', message1);

        end       
            
    elseif GetResponse == 1
        % reset trial variable        
        % collect user input.
            
        if strcmpi(resp, kb_UpArrow)
            % increment y axis of TCA
            tca_green(trial, 2) = tca_green(trial, 2) + 1;
            message1 = [Mov.msg ' increase y TCA'];
            
        elseif strcmpi(resp, kb_DownArrow)
            % decrement y axis of TCA
            tca_green(trial, 2) = tca_green(trial, 2) - 1;
            message1 = [Mov.msg ' decrease y TCA'];
            
        elseif strcmpi(resp, kb_RightArrow)
            % increment x axis of TCA
            tca_green(trial, 1) = tca_green(trial, 1) + 1;
            message1 = [Mov.msg ' increase x TCA'];
            
        elseif strcmpi(resp, kb_LeftArrow)
            % decrement x axis of TCA
            tca_green(trial, 1) = tca_green(trial, 1) - 1;
            message1 = [Mov.msg ' decrease x TCA'];
            
        elseif strcmpi(resp, kb_DecrementTrial)
            trial = trial - 1;
            PresentStimulus = 1;
            message1 = [Mov.msg ' trial: ' num2str(trial)];
            
        elseif strcmpi(resp, kb_IncrementTrial)
            trial = trial + 1;
            PresentStimulus = 1;
            message1 = [Mov.msg ' trial: ' num2str(trial)];
            
        else                
            % All other keys are not valid.
            message1 = [Mov.msg ' ' resp ' not valid response key'];
        end

        if trial > size(tca_green, 1)
            PresentStimulus = 0;
            TerminateExp;
            uiresume;
            message = ['Off - Experiment Aborted - Trial ' ...
                num2str(trial) ' of ' num2str(size(tca_green, 1))];
            set(handles.aom1_state, 'String', message);
        end
        
        % display user response.
        set(handles.aom1_state, 'String', message1);

    end
    filename = ['tca_',strrep(strrep(strrep(datestr(now),'-',''),...
        ' ','x'),':',''),'.mat'];
    save(fullfile(VideoParams.videofolder, filename), 'tca_green');
    
end

end
