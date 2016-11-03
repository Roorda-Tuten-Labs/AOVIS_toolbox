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
        hAomControl = getappdata(0,'hAomControl');
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

% !!
% !! Not sure what this is doing. Looks like it is never accessed.
% !! 
SLR = 0;
if SLR ~= 0
    netcomm('write',SYSPARAMS.netcommobj,int8('RunSLR#'));
    pause(1);
%     netcomm('write',SYSPARAMS.netcommobj,int8('Fix#'));
%     command = ['Locate#' num2str(20) '#' num2str(20) '#']; %#ok<NASGU>
%     netcomm('write',SYSPARAMS.netcommobj,int8(command));
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

tca_red   = [CFG.red_x_offset CFG.red_y_offset];
tca_green = [CFG.green_x_offset CFG.green_y_offset];

cone_selection_method = CFG.cone_selection;
subject_initials = CFG.initials;
% ------------------------------------------------------------- %

% get user input about cone locations
choice = questdlg('Would you like to use last offsets', ...
     'New or repeat', ...
     'Repeat previous experiment','New offsets from old/new movie',...
     'Repeat previous experiment'); % last one repeated b/c it is default option

% based on input do one of two things:
switch choice
  case 'Repeat previous experiment'
    listing_offset_dir = dir(fullfile('.', ...
                                      'color_naming_offsets', '*.mat'));
    offset_filename = fullfile('.', 'color_naming_offsets', ...
                       listing_offset_dir(find(datenum(...
                           {listing_offset_dir(:).date}) == max(max(...
                               datenum({listing_offset_dir(:).date}))))).name);
    load(offset_filename); 
     
  case 'New offsets from old/new movie'

    % name of folder with offsets
    folder_name = fullfile(VideoParams.rootfolder, subject_initials, filesep);

    % gen new offsets
    [offsets_x_y, X_cross_loc, Y_cross_loc] = color_naming.cone_select(...
        tca_red, cone_selection_method, folder_name);

    % check for dir, name and save offsets for later
    if ~isdir('color_naming_offsets')
        mkdir('color_naming_offsets');
    end
    offset_filename = fullfile('.', 'color_naming_offsets', ...
                       [subject_initials, '_offsets_',...
                       strrep(strrep(strrep(datestr(now),'-',''),' ','x'),':',''), ...
                       '.mat']);                                       
    save(offset_filename,'offsets_x_y', 'X_cross_loc', 'Y_cross_loc', ...
         'tca_red');

 end

num_locations = size(offsets_x_y,1);

offsets_x_y = offsets_x_y - repmat([X_cross_loc, Y_cross_loc],num_locations,1);
sequence = reshape(ones(ntrials,1)*(1:num_locations),1,num_locations*ntrials);

%%%%%%% THIS SECTION FOR SETTING INTENSITIES %%%%%%%%%
sequence_with_intensities = repmat(sequence,1,length(intensities));

intensities_sequence = repmat(intensities,ntrials.*num_locations,1);
intensities_sequence = reshape(intensities_sequence,1, ...
                               length(sequence_with_intensities));

% now randominze
randids_with_intensity = randperm(numel(sequence_with_intensities));
sequence_rand = sequence_with_intensities(randids_with_intensity);
intensities_sequence_rand =  intensities_sequence(randids_with_intensity);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% %%%%%%TCA  check%%%%%%%
% offsets_x_y = [0 0];
% num_locations = size(offsets_x_y,1);
% %%%%%%%%%%%%%%%%%%%%%%%


%%%%% Add TCA to the offsets%%%%%%%
tca_red = tca_red.*[-1,+1] ;  % [-1,-1] on ColorNaming_ConeSelction.m

offset_matrix_with_TCA = offsets_x_y + repmat(tca_red,num_locations,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Setup response matrix %%%%%%%
response_matrix = {};
response_matrix.trials = zeros(ntrials*num_locations,1);
response_matrix.coneids = zeros(length(sequence_rand),1);
response_matrix.offsets = zeros(length(sequence_rand),2);
response_matrix.intensities = zeros(length(sequence_rand),1); 

response_matrix.uniqueoffsets = offsets_x_y;

response_matrix.answer = zeros(ntrials*num_locations*length(intensities),Nscale);


%%%% set up the movie parameters %%%%
Mov.dir = dirname;
Mov.suppress = 0;
Mov.pfx = fprefix;

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

%  fprintf(psyfid,'%s\r\nVideoFolder: %s\r\n', num2str(stimsize), VideoParams.videofolder);

% fprintf(psyfid, '%s\t %s\t %s\r\n', 'Trial#', 'Resp.', 'Test Int');

SYSPARAMS.aoms_state(2)=1; % SWITCH RED ON
SYSPARAMS.aoms_state(3)=1; % SWITCH GREEN ON


startframe = 3;
fps = 30;
presentdur = CFG.presentdur/1000;
stimdur = round(fps*presentdur); %how long is the presentation
numframes = fps*CFG.videodur;
endframe = startframe + stimdur - 1; 

framenum = 2; %the index of your bitmap
framenum2 = 3;
framenum3 = 4;

aom1seq = [zeros(1,startframe-1), ...
           ones(1,stimdur).*framenum, zeros(1,30-startframe+1-stimdur)];
aom1pow = ones(size(aom1seq)); % usual
aom1pow(:) = 1; % usual

% --------- Ram was aiming to make a ramping stimulus?? ---------- %
% aom1pow = zeros(size(aom1seq));
% Flat top increment
% aom1pow (find(aom1seq)) = 1;

% Flat top decrement
% length_decrement = floor(stimdur/2) ;
% if rem(length_decrement,2) == 0, length_decrement = length_decrement - 1;end
% aom1pow (startframe : startframe + (stimdur-length_decrement)/2 - 1) = 1;
% aom1pow(startframe + (stimdur-length_decrement)/2  : startframe + (stimdur-length_decrement)/2  + length_decrement -1) = 0;
% aom1pow (endframe - (stimdur - length_decrement)/2 + 1:endframe) = 1;
% aom1seq = aom1pow; 
% aom1seq = aom1seq.*framenum; 

%Increasing linear
% slope = 1; 
% temp = (slope/stimdur).*(0:round(stimdur/slope));
% aom1pow(startframe:startframe + round(stimdur/slope)) = temp;
% aom1seq = aom1pow; 
% aom1seq(find(aom1seq)) = framenum;
% trialIntensity = aom1pow;
% ----------------------------------------------------- %

aom1offx = zeros(size(aom1seq));
aom1offy = zeros(size(aom1seq));

aom1offx_mat = zeros(length(aom1seq),length(aom1seq),num_locations);
aom1offy_mat = zeros(length(aom1seq),length(aom1seq),num_locations);

% !! No idea what this means !!
%%%%%%%%%%%%%%%%%%%%%%%% Change back when using offsets from stabilized
%%%%%%%%%%%%%%%%%%%%%%%% cone movie%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for loc = 1:num_locations
    aom1offx_mat(:,:,loc) = offset_matrix_with_TCA(loc,1);
    aom1offy_mat(:,:,loc) = offset_matrix_with_TCA(loc,2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%% AOM0 (IR) parameters %%%%%%%%%%%%%%%%

% aom0seq = ones(size(aom1seq));
% aom0seq = zeros(size(aom1seq));
% aom0seq = [zeros(1,cueframe-1) ones(1,stimdur).*framenum3 zeros(1,30-startframe+1-stimdur)];
aom0seq = [zeros(1,startframe-1) ones(1,stimdur).*framenum2 zeros(1,30-startframe+1-stimdur)];
aom2seq = [zeros(1,startframe-1) ones(1,stimdur).*framenum2 zeros(1,30-startframe+1-stimdur)];

aom0locx = zeros(size(aom1seq));
aom0locy = zeros(size(aom1seq));
aom0pow = ones(size(aom1seq));
aom0pow(:) = 0;

aom2pow = ones(size(aom1seq));
aom2pow(:) = 100; % 0.25 in ColorNaming_ConeSelection.m
aom2locx = zeros(size(aom1seq));
aom2locy = zeros(size(aom1seq));
aom2offx = zeros(size(aom1seq));
aom2offx(:) = 100;
aom2offy = zeros(size(aom1seq));
aom2offy(:) = 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gainseq = CFG.gain*ones(size(aom1seq));
angleseq = zeros(size(aom1seq));
stimbeep = zeros(size(aom1seq));
stimbeep(startframe+stimdur-1) = 1;
%stimbeep = [zeros(1,startframe+stimdur-1) 1 zeros(1,30-startframe-stimdur+2)];
%Set up movie parameters
Mov.duration = size(aom1seq,2);

Mov.aom0seq = aom0seq;
% Mov.aom0seq = ones(size(aom0seq,2)); %comment when running online
Mov.aom1seq = aom1seq;
Mov.aom0pow = aom0pow;

Mov.aom1pow = aom1pow;
Mov.aom0locx = aom0locx;
Mov.aom0locy = aom0locy;
Mov.aom1offx = aom1offx;
Mov.aom1offy = aom1offy;

Mov.aom2seq = aom2seq;
% Mov.aom2seq = zeros(size(aom2seq,2)); %comment when running online
Mov.aom2pow = aom2pow;
Mov.aom2locx = aom2locx;
Mov.aom2locy = aom2locy;
Mov.aom2offx = aom2offx;
Mov.aom2offy = aom2offy;

Mov.gainseq = gainseq;
Mov.angleseq = angleseq;
Mov.stimbeep = stimbeep;
Mov.frm = 1;
Mov.seq = '';

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
        set(handles.aom1_state, 'String',message);
            
    % check if present stimulus button was pressed
    elseif strcmp(resp, kb_StimConst)
        if PresentStimulus == 1
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
            
            % !!
            % !! Looks like bitnumber and laser_sel are not in use !!
            % !!
            laser_sel = 0;
            if SYSPARAMS.realsystem == 1 && SYSPARAMS.board == 'm'
                bitnumber = round(8191*(2*trialIntensity-1));
            else
                bitnumber = round(trialIntensity*1000);
            end

            % set movie parameters to be played by aom
            Mov.duration = CFG.videodur*fps;
            Mov.frm = 1;

            %Mov.aom1pow(:) = 1; 
            %Mov.aom0pow(:) = 1;
            Mov.aom1pow(:) = intensities_sequence_rand(trial);
            Mov.aom0pow(:) = 1;

            % tell the aom about the offset (includes TCA and cone location)
            Mov.aom1offx = aom1offx_mat(1,:,sequence_rand(trial));
            Mov.aom1offy = aom1offy_mat(1,:,sequence_rand(trial));

            % change the message displayed in status bar
            message = ['Running Experiment - Trial ' num2str(trial) ...
                       ' of ' num2str(ntrials*num_locations)];
            Mov.msg = message;
            Mov.seq = '';

            % send the Mov structure to app data
            setappdata(hAomControl, 'Mov', Mov);
            
            VideoParams.vidname = [CFG.vidprefix '_' sprintf('%03d',trial)];

            %   command = ['UpdatePower#' num2str(laser_sel) '#' ...
            %   num2str(bitnumber) '#'];            %#ok<NASGU>

            %added to use when running offline
            % VideoParams.vidrecord = 0;   
            
            % use the Mov structure to play a movie
            PlayMovie;

            % update loop variables
            PresentStimulus = 0;
            GetResponse = 1;

        else
            message1 = [Mov.msg ' Repeat trial'];   
            GetResponse = 1;
            good_trial = 0;
            sound(sin(0:0.5:90));
            PresentStimulus = 1;
            set(handles.aom1_state, 'String',message1);

        end       
            
    elseif GetResponse == 1
        % reset trial variable
        trial_response_vector = zeros(1, Nscale);
        resp_count = 1;
        repeat_trial_flag = 0;
        seen_flag = 1;
        
        % collect user input.
        for resp_count = 1:Nscale
            
            if strcmp(resp,kb_ans1)
                trial_response_vector(resp_count) = 1;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans1_label];
                disp(trial_response_vector);

            elseif strcmp(resp,kb_ans2)
                trial_response_vector(resp_count) = 2;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans2_label];

            elseif strcmp(resp,kb_ans3)
                trial_response_vector(resp_count) = 3;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans3_label];

            elseif strcmp(resp,kb_ans4)
                trial_response_vector(resp_count) = 4;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans4_label];

            elseif strcmp(resp,kb_ans5)
                trial_response_vector(resp_count) = 5;
                message1 = [Mov.msg ' T#: ' num2str(resp_count) '; Color: ' kb_ans5_label];

            elseif strcmp(resp, kb_NotSeen) 
                trial_response_vector(:) = 0; % set the whole vector to 0.
                message1 = [Mov.msg ' Not Seen'];
                seen_flag = 0;

            elseif strcmp(resp, kb_BadConst) || strcmp(resp, kb_StimConst)
            % Handle press of space bar in the middle of entering a string
            % of values.
                message1 = [Mov.msg ' Repeat trial']; 
                repeat_trial_flag = 1;
                resp_count = Nscale;
                
            % if abort key triggered, end experiment safely.
            elseif strcmp(resp, kb_AbortConst);
                runExperiment = 0;
                uiresume;
                TerminateExp;

                message = ['Off - Experiment Aborted - Trial ' num2str(trial) ' of '...
                           num2str(CFG.ntrials)];
                set(handles.aom1_state, 'String',message);
        
            else
                disp(kb_BadConst)
                disp(kb_StimConst)
                disp(strcmp(resp, kb_BadConst))
                disp(strcmp(resp, kb_StimConst))
                
                % All other keys are not valid.
                message1 = [Mov.msg ' ' resp ' not valid response key'];
                resp_count = resp_count - 1;
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
                    % end of response input
                    GetResponse = 0;
                    good_trial = 1;
                    
                end
                resp_count = resp_count + 1;
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
            if(trial > (ntrials*num_locations*length(intensities)))
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

%%%%%%%% Plot the output %%%%%%%%%%%
temp = [AllData.coneids, AllData.intensities, AllData.answer];
% sort rows so that organized by cone ID. (i.e. cone#1, cone#2 ...);
sortrows(temp,1);

figure();
if Nscale == 1
    for loc_index = 1:AllData.num_locations
       subplot(ceil(AllData.num_locations/3), 3, loc_index); 

       cone = temp(temp(:, 1) == loc_index, 3);

       C = categorical(cone, [1 2 3 4 5], {kb_ans1_label(1), kb_ans2_label(1), ...
           kb_ans3_label(1), kb_ans4_label(1), kb_ans5_label(1)});
       histogram(C, 'Normalization', 'probability');

       set(gca, 'FontSize', 15);      
       title(['#', num2str(loc_index) '; N seen: ' num2str(sum(cone < 6))]); 

    end
else
    
    % plot uad diagram here for each cone
    for loc_index = 1:AllData.num_locations
        % set the subplot
        subplot(ceil(AllData.num_locations / 3), 3, loc_index); 

        % select out individual cone's data
        cone = temp(temp(:, 1) == loc_index, 3:end);

        % remove rows with all zeros
        cone = cone(any(cone, 2), :);

        % compute the frequency of seeing
        FoS = round(size(cone, 1) / ntrials, 3);

        title_text = ['#', num2str(loc_index) '; FoS: ' num2str(FoS)];
        
        % plot response data for cone on Uniform Appearance Diagram
        plots.plot_uad(cone, title_text, 10, 13);

    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Subroutines %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function createStimulus(trialIntensity, stimsize, stimshape)

    if strcmp(stimshape, 'square')
        stim_im = zeros(stimsize, stimsize);
        stim_im(1:end,1:end) = 1;

    elseif strcmp(stimshape, 'circle')

        xp =  -fix(stimsize/2)  : fix(stimsize/2);
        [x, y] = meshgrid(xp);
        stim_im = (x.^2 + y.^2) <= (round(stimsize/2)).^2; 
    end

    stim_im = stim_im.*trialIntensity;    

    %Make cross     
    ir_im = ones(21, 21);
    ir_im(:,9:13)=0;
    ir_im(9:13,:)=0;

    if isdir(fullfile(pwd, 'tempStimulus')) == 0;
        mkdir(fullfile(pwd, 'tempStimulus'));
        cd(fullfile(pwd, 'tempStimulus'));

    else
        cd(fullfile(pwd, 'tempStimulus'));
    end

    blank_im = zeros(10,10);
    imwrite(stim_im,'frame2.bmp');
    imwrite(blank_im,'frame3.bmp');
    imwrite(ir_im,'frame4.bmp');
    cd ..;

end     

function startup
    dummy=ones(10,10);
    if isdir(fullfile(pwd,'tempStimulus')) == 0;
        mkdir(fullfile(pwd,'tempStimulus'));
        cd(fullfile(pwd,'tempStimulus'));
        imwrite(dummy,'frame2.bmp');
    else
        cd(fullfile(pwd,'tempStimulus'));
        delete ('*.*');
        imwrite(dummy,'frame2.bmp');
    end
    cd ..;
end

end
