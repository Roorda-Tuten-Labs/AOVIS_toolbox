function Test_Delivery

% --------------- Parameters --------------- %

% Intensity levels. Usually set to 1, can be a vector with multiple 
% intensities that will be randomly presented.
intensities = 1; %[0.5, 0.75, 1];
nintensities = length(intensities);

% ------------------------------------------- %

% set some variable to global. most of these are first modified 
% by AOMcontrol.m
global SYSPARAMS StimParams VideoParams; %#ok<NUSED>


% get experiment config data stored in appdata for 'hAomControl'
hAomControl = getappdata(0,'hAomControl');

% generate some default stimuli
stim.create_default_stim();

% now wait for ui to load
CFG = AOSLO_experiments.HueScaling_CFG_gui();
CFG.videodur = 1.0;
CFG.angle = 0;

if isstruct(CFG) == 1;
    if CFG.ok == 1
        StimParams.stimpath = fullfile(pwd, 'tempStimulus', filesep);
        VideoParams.vidprefix = CFG.initials;

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

CFG.ntrials = 1;
CFG.nscale = 1;

% get handle to aom gui
handles = aom.setup_aom_gui();

% setup the keyboard constants and response mappings from config
kb_StimConst = 'space';
%kb_Enter = 'a';
kb_BadConst = 'return';

% ------- these options were set in dialog option box ---------- %
kb_ans1 = '1';  
kb_ans1_label = 'red';

kb_AbortConst = 'escape';

dirname = fullfile(StimParams.stimpath, filesep);
fprefix = StimParams.fprefix;
% ------------------------------------------------------------- %

% ---- Setup Mov structure ---- %
Mov = aom.generate_mov(CFG);
Mov.dir = dirname;
Mov.suppress = 0;
Mov.pfx = fprefix;

Mov.aom2pow(:) = 1;
Mov.aom0pow(:) = 1;

% ---- Find user specified TCA ---- %
tca_green = [CFG.green_x_offset CFG.green_y_offset];

% ---- Select cone locations ---- %
[stim_offsets_xy, X_cross_loc, Y_cross_loc] = color_naming.select_cone_gui(...
    tca_green, VideoParams.rootfolder, CFG);

CFG.num_locations = size(stim_offsets_xy,1);
cross_xy = [X_cross_loc, Y_cross_loc];

% ---- Apply TCA offsets to cone locations ---- %
[aom2offx_mat, aom2offy_mat] = aom.apply_TCA_offsets_to_locs(...
    tca_green(1, :), cross_xy, stim_offsets_xy, length(Mov.aom2seq), CFG.system);

% ---- Setup response matrix ---- %
exp_data = {};
exp_data.trials = 1:length(stim_offsets_xy);
exp_data.offsets = stim_offsets_xy;

% Turn ON AOMs
SYSPARAMS.aoms_state(1)=1;
SYSPARAMS.aoms_state(2)=1; % SWITCH RED ON
SYSPARAMS.aoms_state(3)=1; % SWITCH GREEN ON

StimParams.stimpath = dirname;
StimParams.fprefix = fprefix;
StimParams.fext = 'bmp';
            
% Set initial while loop conditions
runExperiment = 1;
trial = 1;
PresentStimulus = 1;
GetResponse = 0;
good_trial = 0;
set(handles.aom_main_figure, 'KeyPressFcn','uiresume');

stim.createStimulus(CFG.stimsize, CFG.stimshape);

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
            sound(cos(90:0.75:180));            
            
            % update system params with stim info
            if SYSPARAMS.realsystem == 1
                StimParams.sframe = 2;
                StimParams.eframe = 4;                
                Parse_Load_Buffers(0);
            end

            % ---- set movie parameters to be played by aom ---- %

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
            good_trial = 0;
            % Play sound.
            sound(sin(0:0.5:90));
            PresentStimulus = 1;
            % Update message
            message1 = [Mov.msg ' Repeat trial'];
            set(handles.aom1_state, 'String', message1);

        end       
            
    elseif GetResponse == 1
        % reset trial variable
        trial_response_vector = zeros(1, CFG.nscale);
        resp_count = 1;
        repeat_trial_flag = 0;
        seen_flag = 1;
        
        % collect user input.
        while resp_count <= CFG.nscale && seen_flag
            
            if strcmp(resp,kb_ans1)
                trial_response_vector(resp_count) = 1;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans1_label];
                resp_count = resp_count + 1;

            elseif strcmp(resp, kb_BadConst) || strcmp(resp, kb_StimConst)
            % Handle press of space bar in the middle of entering a string
            % of values.
                message1 = [Mov.msg ' Repeat trial']; 
                repeat_trial_flag = 1;
                resp_count = CFG.nscale + 1; % ensure trial ends
                
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
            
            if repeat_trial_flag < 1
                % if not repeat trial:
                if resp_count <= CFG.nscale && seen_flag
                    uiwait;
                    % get next response
                    resp = get(handles.aom_main_figure,'CurrentKey');
                    
                else
                    % end of response input, move on to saving response
                    GetResponse = 0;
                    good_trial = 1;
                end
                
            else
                % repeat trial
                GetResponse = 0;
                good_trial = 0;
            end
            
        end
    end
    
    if GetResponse == 0
        % save response
        if good_trial
            message2 = num2str(trial_response_vector);
            set(handles.aom1_state, 'String',message2);
            exp_data.trials(trial) = trial;
            exp_data.offsets(trial,:) = stim_offsets_xy(trial, :);

            sound(cos(0:0.5:90));
            pause(0.2);
            
            %update trial counter
            trial = trial + 1;
            if(trial > (CFG.ntrials * CFG.num_locations * nintensities))
                runExperiment = 0;
                set(handles.aom_main_figure, 'keypressfcn','');
                TerminateExp;
                message = 'Off - Experiment Complete';
                set(handles.aom1_state, 'String', message);
            end
        end
        PresentStimulus = 1;
    end
end

% save data
filename = ['data_color_naming_',strrep(strrep(strrep(datestr(now),'-',''),...
    ' ','x'),':',''),'.mat'];
save(fullfile(VideoParams.videofolder, filename), 'exp_data');

disp([aom2offx_mat(1, 1, :); aom2offx_mat(1, 1, :)]);



end