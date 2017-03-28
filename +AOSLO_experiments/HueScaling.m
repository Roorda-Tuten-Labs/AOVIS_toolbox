function HueScaling
% import external library functions
import color_naming.*
import aom.*
import util.*
import plots.*
import stim.*
import AOSLO_experiments.*

% --------------- Parameters --------------- %
random_flicker = 0;
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


% get handle to aom gui
handles = aom.setup_aom_gui();

% Intensity levels. Usually set to 1, can be a vector with multiple 
% intensities that will be randomly presented.
if CFG.run_intensity_sequence
    intensities = [0.25, 0.5, 1];    
else
    intensities = 1;
end
nintensities = length(intensities);

% setup the keyboard constants and response mappings from config
kb_StimConst = 'space';
%kb_Enter = 'a';
kb_BadConst = 'return';

% ------- these options were set in dialog option box ---------- %
kb_ans1 = '1';  
kb_ans1_label = {'1', 'red'};
kb_ans2 = '2';  
kb_ans2_label = {'2', 'green'};
kb_ans3 = '3';  
kb_ans3_label = {'3', 'blue'};
kb_ans4 = '4';  
kb_ans4_label = {'4', 'yellow'};
kb_ans5 = '5';  
kb_ans5_label = {'5', 'white'};

kb_NotSeen = 'backquote';

kb_AbortConst = 'escape';

dirname = fullfile(StimParams.stimpath, filesep);
fprefix = StimParams.fprefix;
% ------------------------------------------------------------- %

% ---- Setup Mov structure ---- %
Mov = aom.generate_mov(CFG);
Mov.dir = dirname;
Mov.suppress = 0;
Mov.pfx = fprefix;

% ---- Find user specified TCA ---- %
tca_green = [CFG.green_x_offset CFG.green_y_offset];

% ---- Select cone locations ---- %
[stim_offsets_xy, X_cross_loc, Y_cross_loc] = color_naming.select_cone_gui(...
    tca_green, VideoParams.rootfolder, CFG);
cross_xy = [X_cross_loc, Y_cross_loc];

CFG.num_locations = size(stim_offsets_xy,1);

% ---- Apply TCA offsets to cone locations ---- %
[aom2offx_mat, aom2offy_mat] = aom.apply_TCA_offsets_to_locs(...
    tca_green(1, :), cross_xy, stim_offsets_xy, length(Mov.aom2seq), CFG.system);

% ---- Set intensities ---- %
% this section is essentially meaningless if intensities above is only a
% single value (1) as it is typically set.

add_blank_trials = 0;
fraction_blank = CFG.fraction_blank;
if fraction_blank > 0
    add_blank_trials = 1;
end

% first handle case where adding in blank trials
if add_blank_trials
    n_blank_trials_per_cone = ceil(CFG.ntrials * fraction_blank);
    CFG.ntrials = CFG.ntrials + n_blank_trials_per_cone;
end
sequence = reshape(ones(CFG.ntrials, 1) * (1:CFG.num_locations), 1, ...
    CFG.num_locations * CFG.ntrials);
sequence_with_intensities = repmat(sequence, 1, nintensities);

intensities_sequence = repmat(intensities, CFG.ntrials .* CFG.num_locations, 1);
intensities_sequence = reshape(intensities_sequence, 1, ...
                               length(sequence_with_intensities));
if add_blank_trials
    % -- this is where 0 intensities are added to the sequence -- %
    % new total number of trials with blanks added
    total = length(intensities_sequence);
    % number of blanks across the dataset
    nblanks = n_blank_trials_per_cone * CFG.num_locations * nintensities;
    % find indexes so that each cone receives same number of blanks
    blank_indexes = 1:total/nblanks:total;
    % now switch intensites to 0 for each cone at desired rate
    intensities_sequence(blank_indexes) = 0;
end

% now randominze
randids_with_intensity = randperm(numel(sequence_with_intensities));
sequence_rand = sequence_with_intensities(randids_with_intensity);
intensities_sequence_rand =  intensities_sequence(randids_with_intensity);

% ---- Setup response matrix ---- %
exp_data = {};
exp_data.trials = zeros(CFG.ntrials * CFG.num_locations, 1);
exp_data.coneids = zeros(length(sequence_rand), 1);
exp_data.offsets = zeros(length(sequence_rand), 2);
exp_data.intensities = zeros(length(sequence_rand), 1); 
exp_data.uniqueoffsets = stim_offsets_xy;
exp_data.answer = zeros(CFG.ntrials * CFG.num_locations * ...
    nintensities, CFG.nscale);

% Save param values for later
CFG.vidprefix = CFG.initials;

exp_data.experiment = 'Color Naming Basic';
exp_data.subject  = ['Observer: ' CFG.initials];
exp_data.pupil = ['Pupil Size (mm): ' CFG.pupilsize];
exp_data.field = ['Field Size (deg): ' num2str(CFG.fieldsize)];
exp_data.presentdur = ['Presentation Duration (ms): ' num2str(CFG.presentdur)];
exp_data.videoprefix = ['Video Prefix: ' CFG.vidprefix];
exp_data.videodur = ['Video Duration: ' num2str(CFG.videodur)];
exp_data.videofolder = ['Video Folder: ' VideoParams.videofolder];
exp_data.brightness_scaling = CFG.brightness_scaling;
exp_data.stimsize = CFG.stimsize;
exp_data.ntrials = CFG.ntrials;
exp_data.num_locations = CFG.num_locations;
exp_data.Nscale = CFG.nscale;
exp_data.cnames = {kb_ans1_label{2}, kb_ans2_label{2}, kb_ans3_label{2}, ...
    kb_ans4_label{2}, kb_ans5_label{2}};
exp_data.seed = 45245801;

% Turn ON AOMs
SYSPARAMS.aoms_state(1)=1;
SYSPARAMS.aoms_state(2)=1; % SWITCH RED ON
SYSPARAMS.aoms_state(3)=1; % SWITCH GREEN ON

StimParams.stimpath = dirname;
StimParams.fprefix = fprefix;
StimParams.fext = 'bmp';
% --------------------------------------------------- %
% --------------- Begin Experiment ------------------ %
% --------------------------------------------------- %
if random_flicker == 1
    rng(exp_data.seed);
    stim.createRandomStimulus(1, CFG.stimsize);
else
    stim.createStimulus(CFG.stimsize, CFG.stimshape);
end

% Set initial while loop conditions
runExperiment = 1;
trial = 1;
PresentStimulus = 1;
GetResponse = 0;
good_trial = 0;
set(handles.aom_main_figure, 'KeyPressFcn','uiresume');

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
            % sound(cos(90:0.75:180));            
            beep 
            
            % update system params with stim info
            if SYSPARAMS.realsystem == 1
                StimParams.sframe = 2;
                if CFG.random_flicker == 1
                    StimParams.eframe = 28;
                else
                    StimParams.eframe = 4;
                end
                Parse_Load_Buffers(0);
            end

            % ---- set movie parameters to be played by aom ---- %
            % Select AOM power 100% for most experiments unless set 
            % otherwise with intensity variable at top of file.
            Mov.aom2pow(:) = 1;%
            stim.createStimulus(CFG.stimsize, CFG.stimshape, intensities_sequence_rand(trial));
            Mov.aom0pow(:) = 1;

            % tell the aom about the offset (TCA + cone location)
            Mov.aom2offx = aom2offx_mat(1, :, sequence_rand(trial));
            Mov.aom2offy = aom2offy_mat(1, :, sequence_rand(trial));

            if CFG.random_flicker == 1
                % find frames that have intensities set to greater than 0
                on_frames = Mov.aom2seq > 0;
                n_on_frames = sum(on_frames);
                
                % use selected starting locations and randomly walk from
                % there
                rand_ind = randi([4, 28], n_on_frames, 1);
                
                % update offsets sent to aom2
                Mov.aom2seq(on_frames) = rand_ind;
                
            end
            
            % change the message displayed in status bar
            message = ['Running Experiment - Trial ' num2str(trial) ...
                       ' of ' num2str(CFG.ntrials * CFG.num_locations * nintensities)];
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
            %sound(sin(0:0.5:90));
            beep
            
            PresentStimulus = 1;
            % Update message
            message1 = [Mov.msg ' Repeat trial'];
            set(handles.aom1_state, 'String', message1);

        end       
            
    elseif GetResponse == 1
        % reset trial variable
        total_button_presses = CFG.nscale + CFG.brightness_scaling;
        trial_response_vector = zeros(1, total_button_presses);
        resp_count = 1;
        repeat_trial_flag = 0;
        seen_flag = 1;
        
        % collect user input.
        while resp_count <= total_button_presses && seen_flag
            if CFG.brightness_scaling && resp_count == 1
                ind = 1;
            else
                ind = 2;
            end
            if strcmp(resp,kb_ans1)
                trial_response_vector(resp_count) = 1;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) ...
                    '; Color: ' kb_ans1_label{ind}];
                resp_count = resp_count + 1;
                    
            elseif strcmp(resp,kb_ans2)
                trial_response_vector(resp_count) = 2;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) ...
                    '; Color: ' kb_ans2_label{ind}];
                resp_count = resp_count + 1;

            elseif strcmp(resp,kb_ans3)
                trial_response_vector(resp_count) = 3;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) ...
                    '; Color: ' kb_ans3_label{ind}];
                resp_count = resp_count + 1;

            elseif strcmp(resp,kb_ans4)
                trial_response_vector(resp_count) = 4;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) ...
                    '; Color: ' kb_ans4_label{ind}];
                resp_count = resp_count + 1;

            elseif strcmp(resp,kb_ans5)
                trial_response_vector(resp_count) = 5;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) ...
                    '; Color: ' kb_ans5_label{ind}];
                resp_count = resp_count + 1;

            elseif strcmp(resp, kb_NotSeen) 
                trial_response_vector(:) = 0; % set the whole vector to 0.
                message1 = [Mov.msg ' Not Seen'];
                seen_flag = 0;

            elseif strcmp(resp, kb_BadConst) || strcmp(resp, kb_StimConst)
            % Handle press of space bar in the middle of entering a string
            % of values.
                message1 = [Mov.msg ' Repeat trial']; 
                repeat_trial_flag = 1;
                resp_count = total_button_presses + 1; % ensure trial ends
                
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
                if resp_count <= total_button_presses && seen_flag
                    % let the subject know that brightness rating has been
                    % registered.
                    if CFG.brightness_scaling && resp_count == 2
                        beep;
                    end
                        
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
            exp_data.trials (trial) = trial;
            exp_data.coneids (trial) = sequence_rand(trial);
            exp_data.offsets(trial,:) = [stim_offsets_xy(...
                sequence_rand(trial),1) stim_offsets_xy(sequence_rand(trial),2)];
            exp_data.intensities (trial) = intensities_sequence_rand(trial);

            % record data according to whether or not brightness was rated.
            if CFG.brightness_scaling
                exp_data.answer(trial, :) = trial_response_vector(2:end);
                exp_data.brightness_rating(trial) = trial_response_vector(1);
            else
                exp_data.answer(trial, :) = trial_response_vector;
            end
            %sound(cos(0:0.5:90));
            beep;
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

disp(exp_data);

% save data
filename = ['data_color_naming_',strrep(strrep(strrep(datestr(now),'-',''),...
    ' ','x'),':',''),'.mat'];
save(fullfile(VideoParams.videofolder, filename), 'exp_data');

% plot data
color_naming.plot_color_naming(exp_data);


end
