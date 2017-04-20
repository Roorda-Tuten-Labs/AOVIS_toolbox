% test_add_cone_types_to_selection_img
 
testdir = fileparts(which('cone_mosaic.add_cone_types_to_selection_img'));

fname = fullfile(testdir, 'cone_identify', 'test', ...
    'sumnorm_20076R_5.tif');
selection_img = imread(fname);
%selection_img = imread('cone_identify/test/20076R_1.png');
%selection_img = imresize(selection_img, 0.2);
%selection_img = uint8(selection_img(:, :, 1));
xy_cross_loc = [300 400];

    
cone_mosaic.add_cone_types_to_selection_img('20076R', selection_img,...
    xy_cross_loc);