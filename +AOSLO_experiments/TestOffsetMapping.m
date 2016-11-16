function TestOffsetMapping
% import external library functions
import color_naming.*
import util.*

% --------------- Parameters --------------- %

% ------------------------------------------- %

% set some variable to global. most of these are first modified 
% by AOMcontrol.m
global SYSPARAMS StimParams VideoParams; %#ok<NUSED>

% get a handle to the gui so that we can change its appearance later
if exist('handles','var') == 0;
    handles = guihandles;
end

% This is a subroutine located at the end of this file. Generates some
% default stimuli
startup;

% get experiment config data stored in appdata for 'hAomControl'
hAomControl = getappdata(0,'hAomControl');

% now wait for ui to load
CFG = AOSLO_experiments.HueScaling_CFG_load();
CFG.videodur = 1.0;
CFG.angle = 0;

if isstruct(CFG) == 1;
    if CFG.ok == 1
        StimParams.stimpath = fullfile(pwd, 'tempStimulus', filesep);  % CFG.stimpath;
        VideoParams.vidprefix = CFG.vidprefix;

        if CFG.record == 1;
            VideoParams.videodur = CFG.videodur;
        end

        % save the CFG file for next time
        save(fullfile('Experiments', 'lastBasicCFG.mat'), 'CFG');
        
        % sets VideoParam variables
        set_VideoParams_PsyfileName();  

        set(handles.aom1_state, 'String', 'Configuring Experiment...');
        
        % Appears to load stimulus into buffer. Called here with parameter
        % set to 1. This seems to load some default settings. Later calls
        % send user defined settings via netcomm.
        Parse_Load_Buffers(1);

        % change appearance of AOM control window   
        set(handles.image_radio1, 'Enable', 'off');
        set(handles.seq_radio1, 'Enable', 'off');
        set(handles.im_popup1, 'Enable', 'off');
        set(handles.display_button, 'String', 'Running Exp...');
        set(handles.display_button, 'Enable', 'off');
        set(handles.aom1_state, 'String', 'On - Experiment Mode - Running Experiment');
    else
        return;
    end
end



dirname = fullfile(StimParams.stimpath, filesep);
fprefix = StimParams.fprefix;
% ------------------------------------------------------------- %

% ---- Setup Mov structure ---- %
Mov = color_naming.generate_mov(CFG);
Mov.dir = dirname;
Mov.suppress = 0;
Mov.pfx = fprefix;
    
% ---- Get TCA offsets ---- %
tca_red = [0 0];
% translate image space to stimulus space (invert directions).
tca_red = tca_red .*  [-1, -1];

tca_green = [0 0];
tca_green = tca_green .*  [-1, -1];

X_loc = [-25 25 -25 25];
Y_loc = [25 25 -25 -25];

offsets_x_y = [X_loc Y_loc] - repmat([0, 0], size(X_loc),1);

% ------ Add TCA to the offsets ------ %
offset_matrix_with_TCA = offsets_x_y + repmat(tca_green, size(offsets_x_y, 1), 1);

% ---- Select locations ---- %
% Set up AOM TCA offset mats
aom2offx_mat = zeros(length(Mov.aom2seq), length(Mov.aom2seq), size(offsets_x_y, 1));
aom2offy_mat = zeros(length(Mov.aom2seq), length(Mov.aom2seq), size(offsets_x_y, 1));

%%% Change back when using offsets from stabilized cone movie %%%
for loc = 1:size(offsets_x_y, 1)
    aom2offx_mat(:, :, loc) = offset_matrix_with_TCA(loc, 1);
    aom2offy_mat(:, :, loc) = offset_matrix_with_TCA(loc, 2);
end


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
kb_Repeat = 'enter';
kb_LeftArrow = 'leftarrow';
kb_RightArrow = 'rightarrow';

% generate stimulus based on size, shape and intensity.
createStimulus(1, CFG.stimsize, CFG.stimshape);
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
                   num2str(CFG.ntrials)];
        set(handles.aom1_state, 'String', message);
            
    % check if present stimulus button was pressed
    elseif strcmp(resp, kb_StimConst)
        if PresentStimulus == 1
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

            % tell the aom about the offset (TCA + cone location)
            Mov.aom2offx = aom2offx_mat(1, :, trial);
            Mov.aom2offy = aom2offy_mat(1, :, trial);
            
            % change the message displayed in status bar
            message = ['Running Experiment - Trial ' num2str(trial) ...
                       ' of ' num2str(CFG.ntrials * CFG.num_locations)];
            Mov.msg = message;
            Mov.seq = '';
            
            % send the Mov structure to app data
            setappdata(hAomControl, 'Mov', Mov);
            
            VideoParams.vidname = [CFG.vidprefix '_' sprintf('%03d',trial)];

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
            
        if strcmp(resp, kb_Repeat)
        % Handle press of space bar in the middle of entering a string
        % of values.
            message1 = [Mov.msg ' Repeat trial']; 

        elseif strcmp(resp, kb_LeftArrow)
            message1 = [Mov.msg ' trial: ' num2str(trial)];
            trial = trial - 1;
            
        elseif strcmp(resp, kb_RightArrow)
            message1 = [Mov.msg ' trial: ' num2str(trial)];
            trial = trial + 1;
            
        elseif strcmp(resp, kb_StimConst)
            PresentStimulus = 1;
            
        % if abort key triggered, end experiment safely.
        elseif strcmp(resp, kb_AbortConst);
            runExperiment = 0;
            uiresume;
            TerminateExp;
            message = ['Off - Experiment Aborted - Trial ' ...
                num2str(trial) ' of ' num2str(CFG.ntrials)];
            set(handles.aom1_state, 'String', message);

        else                
            % All other keys are not valid.
            message1 = [Mov.msg ' ' resp ' not valid response key'];
        end

        % display user response.
        set(handles.aom1_state, 'String', message1);

    end

    
end


% ---------------------------------- %
% ---------- Subroutines ----------- %
% ---------------------------------- %

function createStimulus(trialIntensity, stimsize, stimshape)

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
    ir_im = ones(21, 21);
    ir_im(:,9:13)=0;
    ir_im(9:13,:)=0;

    if isdir(fullfile(pwd, 'tempStimulus')) == 0;
        mkdir(fullfile(pwd, 'tempStimulus'));
        cd(fullfile(pwd, 'tempStimulus'));

    else
        cd(fullfile(pwd, 'tempStimulus'));
    end

    blank_im = zeros(10, 10);
    
    imwrite(blank_im, 'frame2.bmp');
    imwrite(ir_im, 'frame3.bmp');
    imwrite(stim_im, 'frame4.bmp');
    
    cd ..;

end     

function startup
    dummy=ones(10, 10);
    if isdir(fullfile(pwd, 'tempStimulus')) == 0;
        mkdir(fullfile(pwd, 'tempStimulus'));
        cd(fullfile(pwd, 'tempStimulus'));
        imwrite(dummy, 'frame2.bmp');
    else
        cd(fullfile(pwd, 'tempStimulus'));
        delete ('*.*');
        imwrite(dummy, 'frame2.bmp');
    end
    cd ..;
end

end
