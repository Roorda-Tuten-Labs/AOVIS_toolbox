function CFG = HueScaling_CFG_load()
init_load = 0;
if exist(fullfile('Experiments', 'lastBasicCFG.mat'),'file')==2
    load(fullfile('Experiments', 'lastBasicCFG.mat'));
    CFG.comment = ' ';
    init_load = 1;
    %setappdata(hAomControl, 'CFG', CFG);
end

if init_load == 0 %load defaults    
    CFG.initials = 'test';
    CFG.pupilsize = 7.0;
    CFG.fieldsize = 1.0;
    CFG.presentdur = 500;
    
    CFG.ntrials = 10;
    CFG.gain = 1.0;
    
    CFG.nscale = 1;
    
    CFG.stimsize  = 3;
    CFG.random_flicker = 0;
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
    CFG.comment = ' ';
    CFG.record = 1;
    
    CFG.system = 'aoslo';
    CFG.ok = 1;
    %setappdata(hAomControl, 'CFG', CFG);

end