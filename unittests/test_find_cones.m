function test_find_cones()

    fname = fullfile('dat', ...
        'sumnorm_20076R_V001_stabilized_09Mar2017x110520_421_411.tif');

    im = imread(fname);
    
    [x_interest, y_interest, img_map] = img.find_cones(7, im, 'auto');
    
end