function add_cone_types_to_selection_img(subject, selection_img, ...
    xy_cross_loc)

if ischar(selection_img)
    selection_img = imread('cone_identify/test/sumnorm_20076R_5.tif');
    %selection_img = imread('cone_identify/test/20076R_1.png');
    %selection_img = imresize(selection_img, 0.2);
    %selection_img = uint8(selection_img(:, :, 1));
    if nargin < 3
        xy_cross_loc = [300 400];
    end
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

%buffered_img = img.zero_buffer(selection_img, size(ref));
if size(selection_img, 1) > size(ref, 1) || size(selection_img, 2) > size(ref, 2)
    center = floor(size(selection_img) ./ 2);
    refsize = size(ref);
    croprect = [(center(2) - floor(refsize(2) / 2)), ...
           (center(1) - floor(refsize(1) / 2)),...
           refsize(2) - 1, refsize(1) - 1];

    xy_cross_loc(1) =  xy_cross_loc(1) - (center(2) - floor(refsize(2) / 2));
    xy_cross_loc(2) =  xy_cross_loc(2) - (center(1) - floor(refsize(1) / 2));
    
    % cut the image down to speed up search   
    img_crop = imcrop(selection_img, croprect);
end

% output =  [error,diffphase,net_row_shift,net_col_shift]
output = img.dftregistration(fft2(ref), fft2(img_crop), 1);
offsets = output(3:4);

figure;
if max(max(img_crop)) > 125
    imshow(img_crop, [0 255]);
else
    imshow(img_crop)
end

hold on;
colors = {'b' 'g' 'r'};
for c = 1:size(new_cone_coords, 1)
    cone = new_cone_coords(c, :);
    plot(cone(1) - offsets(2), cone(2) - offsets(1), '.', ...
        'markersize', 16, 'color', colors{cone(3)});
end

plot(xy_cross_loc(1), xy_cross_loc(2), 'y+', 'markersize', 30);
disp(' ');

% x_lim = [min(new_cone_coords(:, 1)) - offsets(2)...
%     max(new_cone_coords(:, 1)) - offsets(2)];
% y_lim = [min(new_cone_coords(:, 2)) - offsets(1) ...
%     max(new_cone_coords(:, 2)) - offsets(1)];
% xlim(x_lim);
% ylim(y_lim);
