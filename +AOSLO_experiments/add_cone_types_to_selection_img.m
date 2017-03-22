function add_cone_types_to_selection_img(subject, selection_img)

if ischar(selection_img)
    selection_img = imread('cone_identify/test/20076R_4.png');
    selection_img = imresize(selection_img, 0.2);
    selection_img = uint8(selection_img(:, :, 1));
end

% load reference image
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
output = img.dftregistration(fft2(ref), fft2(buffered_img), 1);
offsets = output(3:4);

figure;
if max(max(selection_img)) > 125
    imshow(buffered_img, [0 255]);
else
    imshow(buffered_img)
end

hold on;
colors = {'b' 'g' 'r'};
for c = 1:size(new_cone_coords, 1)
    cone = new_cone_coords(c, :);
    plot(cone(1) - offsets(2), cone(2) - offsets(1), '.', ...
        'markersize', 16, 'color', colors{cone(3)});
end

% x_lim = [min(new_cone_coords(:, 1)) - offsets(2)...
%     max(new_cone_coords(:, 1)) - offsets(2)];
% y_lim = [min(new_cone_coords(:, 2)) - offsets(1) ...
%     max(new_cone_coords(:, 2)) - offsets(1)];
% xlim(x_lim);
% ylim(y_lim);
