function HueScaling_SingleCone

import color_naming.*
import util.*
import plots.*
import AOSLO_experiments.*

%%%%% IF VARYING INTENSITY USE THIS %%%%%%%
intensities = [1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nscale = 5;

% set some variable to global. most of these are first modified 
% by AOMcontrol.m
global SYSPARAMS StimParams VideoParams; %#ok<NUSED>

% get a handle to the gui so that we can change its appearane later
if exist('handles','var') == 0;
    handles = guihandles;
end

% This is a subroutine located at the end of this file. Generates some
% default stimuli
startup;

% get experiment config data stored in appdata for 'hAomControl'
hAomControl = getappdata(0,'hAomControl');

% now wait for ui to load
CFG = AOSLO_experiments.HueScaling_CFG_gui();

% get config file from AomControl, stored in appdata folder
%CFG = getappdata(hAomControl, 'CFG');

if isstruct(CFG) == 1;
    %CFG = getappdata(getappdata(0,'hAomControl'),'CFG');
    if CFG.ok == 1
        StimParams.stimpath = fullfile(pwd, 'tempStimulus', filesep);  % CFG.stimpath;
        VideoParams.vidprefix = CFG.vidprefix;
        set(handles.aom1_state, 'String', 'Configuring Experiment...');
        
        if SYSPARAMS.realsystem == 1 && SYSPARAMS.board == 'm'
            set(handles.aom1_state, 'String', ...
                              'Off - Press Start Button To Begin Experiment');
        else
            set(handles.aom1_state, 'String', ...
                              'On - Press Start Button To Begin Experiment');
        end
        
        if CFG.record == 1;
            VideoParams.videodur = CFG.videodur;
        end

        % sets VideoParam variables
        set_VideoParams_PsyfileName();  

        % !! Not sure why this is called again
        % hAomControl = getappdata(0,'hAomControl');
        
        % Not entirely sure what this does
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

CFG.videodur = 1.0;
CFG.angle = 0;

% setup the keyboard constants and response mappings from config
kb_StimConst = 'space';
%kb_Enter = 'a';
kb_BadConst = 'return';

% ------- these options were set in dialog option box ---------- %
kb_ans1 = CFG.ans1;  kb_ans1_label = CFG.ans1_label;
kb_ans2 = CFG.ans2;  kb_ans2_label = CFG.ans2_label;
kb_ans3 = CFG.ans3;  kb_ans3_label = CFG.ans3_label;
kb_ans4 = CFG.ans4;  kb_ans4_label = CFG.ans4_label;
kb_ans5 = CFG.ans5;  kb_ans5_label = CFG.ans5_label;

kb_NotSeen = CFG.ans6;
kb_AbortConst = CFG.ans7;
%kb_ans8 = CFG.ans8;  
%kb_ans8_label = CFG.ans8_label;

stimsize = CFG.stimsize;
stimshape = CFG.stimshape;
ntrials   = CFG.ntrials;

dirname = fullfile(StimParams.stimpath, filesep);
fprefix = StimParams.fprefix;
% ------------------------------------------------------------- %

% Get TCA offsets
tca_red = [CFG.red_x_offset CFG.red_y_offset];
%tca_green = [CFG.green_x_offset CFG.green_y_offset];
tca_red = tca_red.*[-1,+1] ;  % [-1,-1] on ColorNaming_ConeSelction.m

% ---- Select cone locations ---- %
[offsets_x_y, X_cross_loc, Y_cross_loc] = color_naming.select_cone_gui(...
    tca_red, VideoParams.rootfolder, CFG);
num_locations = size(offsets_x_y,1);
offsets_x_y = offsets_x_y - repmat([X_cross_loc, Y_cross_loc],num_locations,1);

% ---- THIS SECTION FOR SETTING INTENSITIES ---- %
sequence = reshape(ones(ntrials,1)*(1:num_locations),1,num_locations*ntrials);
sequence_with_intensities = repmat(sequence,1,length(intensities));

intensities_sequence = repmat(intensities,ntrials.*num_locations,1);
intensities_sequence = reshape(intensities_sequence,1, ...
                               length(sequence_with_intensities));

% now randominze
randids_with_intensity = randperm(numel(sequence_with_intensities));
sequence_rand = sequence_with_intensities(randids_with_intensity);
intensities_sequence_rand =  intensities_sequence(randids_with_intensity);
% -----------------------------------------

% ---- Setup response matrix ---- %
response_matrix = {};
response_matrix.trials = zeros(ntrials * num_locations, 1);
response_matrix.coneids = zeros(length(sequence_rand), 1);
response_matrix.offsets = zeros(length(sequence_rand), 2);
response_matrix.intensities = zeros(length(sequence_rand), 1); 
response_matrix.uniqueoffsets = offsets_x_y;
response_matrix.answer = zeros(ntrials * num_locations * length(intensities),...
    Nscale);

% Save param values for later
exp_parameters = {};
exp_parameters.experiment = 'Color Naming Basic';
exp_parameters.subject  = ['Observer: ' CFG.initials];
exp_parameters.pupil = ['Pupil Size (mm): ' CFG.pupilsize];
exp_parameters.field = ['Field Size (deg): ' num2str(CFG.fieldsize)];
exp_parameters.presentdur = ['Presentation Duration (ms): ' num2str(CFG.presentdur)];
exp_parameters.videoprefix = ['Video Prefix: ' CFG.vidprefix];
exp_parameters.videodur = ['Video Duration: ' num2str(CFG.videodur)];
exp_parameters.videofolder = ['Video Folder: ' VideoParams.videofolder];
exp_parameters.stimsize = stimsize;
exp_parameters.ntrials = ntrials;
exp_parameters.num_locations = num_locations;
exp_parameters.Nscale = Nscale;
exp_parameters.cnames = {kb_ans1_label, kb_ans2_label, kb_ans3_label, ...
    kb_ans4_label, kb_ans5_label};

% Turn ON AOMs
SYSPARAMS.aoms_state(2)=1; % SWITCH RED ON
SYSPARAMS.aoms_state(3)=1; % SWITCH GREEN ON

% Setup Mov structure
Mov = color_naming.generate_mov(CFG);
Mov.dir = dirname;
Mov.suppress = 0;
Mov.pfx = fprefix;

% ------ Add TCA to the offsets ------ %
offset_matrix_with_TCA = offsets_x_y + repmat(tca_red, num_locations, 1);

% Set up AOM TCA offset mats
aom1offx_mat = zeros(length(Mov.aom1seq), length(Mov.aom1seq), num_locations);
aom1offy_mat = zeros(length(Mov.aom1seq), length(Mov.aom1seq), num_locations);

%%% Change back when using offsets from stabilized cone movie %%%
for loc = 1:num_locations
    aom1offx_mat(:, :, loc) = offset_matrix_with_TCA(loc, 1);
    aom1offy_mat(:, :, loc) = offset_matrix_with_TCA(loc, 2);
end
 
% % TCA  check
% offsets_x_y = [0 0];
% num_locations = size(offsets_x_y,1);

% --------------------------------------------------- %

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
            sound(cos(90:0.75:180))
            % 100% for most experiments unless set otherwise with intensity
            % variable at top of file.
            trialIntensity = intensities_sequence_rand(trial);
            % generate stimulus based on size, shape and intensity.
            createStimulus(trialIntensity, stimsize, stimshape);
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
            Mov.aom1pow(:) = intensities_sequence_rand(trial);
            Mov.aom0pow(:) = 1;

            % tell the aom about the offset (TCA + cone location)
            Mov.aom1offx = aom1offx_mat(1, :, sequence_rand(trial));
            Mov.aom1offy = aom1offy_mat(1, :, sequence_rand(trial));

            % change the message displayed in status bar
            message = ['Running Experiment - Trial ' num2str(trial) ...
                       ' of ' num2str(ntrials*num_locations)];
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
        trial_response_vector = zeros(1, Nscale);
        resp_count = 1;
        repeat_trial_flag = 0;
        seen_flag = 1;
        
        % collect user input.
        while resp_count <= Nscale && seen_flag
            
            if strcmp(resp,kb_ans1)
                trial_response_vector(resp_count) = 1;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans1_label];
                resp_count = resp_count + 1;
                    
            elseif strcmp(resp,kb_ans2)
                trial_response_vector(resp_count) = 2;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans2_label];
                resp_count = resp_count + 1;

            elseif strcmp(resp,kb_ans3)
                trial_response_vector(resp_count) = 3;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans3_label];
                resp_count = resp_count + 1;

            elseif strcmp(resp,kb_ans4)
                trial_response_vector(resp_count) = 4;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans4_label];
                resp_count = resp_count + 1;

            elseif strcmp(resp,kb_ans5)
                trial_response_vector(resp_count) = 5;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans5_label];
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
                resp_count = Nscale + 1; % ensure trial ends
                
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
                if resp_count < Nscale && seen_flag
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
            response_matrix.trials (trial) = trial;
            response_matrix.coneids (trial) = sequence_rand(trial);
            response_matrix.answer(trial,:) = trial_response_vector;
            response_matrix.offsets(trial,:) = [offsets_x_y(...
                sequence_rand(trial),1) offsets_x_y(sequence_rand(trial),2)];
            response_matrix.intensities (trial) = intensities_sequence_rand(trial);

            sound(cos(0:0.5:90));
            pause(0.2);
            
            %update trial counter
            trial = trial + 1;
            if(trial > (ntrials * num_locations * length(intensities)))
                runExperiment = 0;
                set(handles.aom_main_figure, 'keypressfcn','');
                TerminateExp;
                message = 'Off - Experiment Complete';
                set(handles.aom1_state, 'String',message);
            end
        end
        PresentStimulus = 1;
    end
end

AllData = util.catstruct(exp_parameters, response_matrix);
disp(AllData);

filename = ['data_color_naming_',strrep(strrep(strrep(datestr(now),'-',''),...
    ' ','x'),':',''),'.mat'];

if isdir(fullfile(pwd,'Data_Color_Naming')) == 0;
    mkdir(pwd,'Data_Color_Naming');
end

save(fullfile(VideoParams.videofolder, filename), 'AllData');

color_naming.plot_color_naming(AllData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Subroutines %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    imwrite(stim_im, 'frame2.bmp');
    imwrite(blank_im, 'frame3.bmp');
    imwrite(ir_im, 'frame4.bmp');
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
