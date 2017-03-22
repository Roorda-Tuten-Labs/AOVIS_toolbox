subject = '20076R';
selection_img = imread('cone_identify/test/20076R_5.png');
selection_img = imresize(selection_img, 0.2);
selection_img = uint8(selection_img(:, :, 1));
datadir = fullfile(fileparts(mfilename('fullpath')), ...
    'cone_identify', subject);
ref = imread(fullfile(datadir, 'ref.tif'));

% load cone coordinates
new_cone_coords = load(fullfile(datadir, 'cone_coord_ref_img_space.mat'));
new_cone_coords = new_cone_coords.new_cone_coords;

% if img comes in a color format, only look at the first dimension
if ndims(selection_img) > 2
    selection_img = selection_img(:, :, 1);
end

buffered_img = img.zero_buffer(selection_img, size(ref));

% output =  [error,diffphase,net_row_shift,net_col_shift]
[output, greg] = img.dftregistration(fft2(ref), fft2(buffered_img), 1);
offsets = output(3:4);

figure; imshow(ref); hold on;
h = imshow(abs(ifft2(greg)), [0 255]);
set(h, 'AlphaData', 0.25)