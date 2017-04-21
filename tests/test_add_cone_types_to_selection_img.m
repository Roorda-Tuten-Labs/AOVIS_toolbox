% test_add_cone_types_to_selection_img
clearvars;

% test image number (select 1-5)
img_n = 5;
% read in test image
testdir = fileparts(which('cone_mosaic.add_cone_types_to_selection_img'));
fname = fullfile(testdir, 'cone_identify', 'test', ...
    ['sumnorm_20076R_' num2str(img_n) '.tif']);
selection_img = imread(fname);
xy_cross_loc = [300 400];
    
cone_mosaic.add_cone_types_to_selection_img('20076R', selection_img,...
    xy_cross_loc);