function CFG = HueScaling_CFG_load()

if exist(fullfile('Experiments', 'lastBasicCFG.mat'),'file')==2
    CFG = load(fullfile('Experiments', 'lastBasicCFG.mat'));
    CFG.comment = ' ';
    init_load = 1;
    %setappdata(hAomControl, 'CFG', CFG);
end

if (init_load == 0) %load defaults    
    CFG.subject = 'test';
    CFG.pupilsize = 7.0;
    CFG.fieldsize = 1.0;
    CFG.presentdur = 500;
    
    CFG.ntrials = 10;
    CFG.gain = 1.0;
    
    CFG.stimsize  = 3;
   
    CFG.stimshape = 'square';
    CFG.cone_selection = 'manual';
    
    CFG.vidprefix = 'test';
    
    %TCA offsets
    CFG.red_x_offset = 0; 
    CFG.red_y_offset = 0; 
    CFG.green_x_offset = 0; 
    CFG.green_y_offset = 0; 

    CFG.stimpath = fullfile(pwd, 'tempStimulus', filesep);
    
    CFG.videodur = 1.0;
    CFG.angle = 0;
    CFG.beep = 1;
    CFG.stimconst = 'space';
    
    
    % Response mapping
    CFG.ans1 = 1;
    CFG.ans2 = 2;
    CFG.ans3 = 3; 
    CFG.ans4 = 4;
    CFG.ans5 = 5;

    CFG.ans1_label = 'red';
    CFG.ans2_label = 'green';
    CFG.ans3_label = 'blue'; 
    CFG.ans4_label = 'yellow';
    CFG.ans5_label = 'white';
    
    CFG.ok = 1;
    %setappdata(hAomControl, 'CFG', CFG);

end