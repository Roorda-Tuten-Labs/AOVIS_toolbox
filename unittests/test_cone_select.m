function test_cone_select()
% Video to test is dat/Video_Files/20076R_V004_stabilized.avi.
%
%
tca = [-18, -2];
rootfolder = fullfile('dat', 'VideoFolder');

CFG.initials = '20076R';
CFG.cone_selection = 'manual';

    
[offsets_x_y, X_cross_loc, Y_cross_loc] = cone_select.main_gui(tca, ...
    rootfolder, CFG);

disp(offsets_x_y);
disp(X_cross_loc);
disp(Y_cross_loc);
end