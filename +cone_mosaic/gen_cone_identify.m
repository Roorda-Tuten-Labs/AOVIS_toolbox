% This script is for generating cone_coord_ref_img_space.mat and
% ref_img_w_conetypes.svg files for a new subject. It requires a mosaic.tif
% and a ref.tif be already set up in the directory 'cone_identify/SUBJECT'.
% The dftregistration does not work perfectly on the cone classed mosaic
% tiff. Therefore, you have to manually play with the mosaic_offset (line
% 41) to get a good match between ref.tif and mosaic.tif.
clearvars;

subject = '10001R';
savedir = fullfile(fileparts(mfilename('fullpath')), ...
    'cone_identify', subject);

% This accounts for differences in scale between the old and new systems
% (i.e. 1.28 vs ~0.95 degree raster sizes). Set this to zero if cone
% classing was done on same system as experiment.
mosaic_scale_factor = 1.28/0.93;

% load reference image
ref = imread(fullfile(savedir, 'ref.tif'));

% % find cone in reference image
% [xlocs, ylocs] = img.find_cones(7, ref);
% ref_cone_locs = [xlocs ylocs;];

% uncomment lines below to crop and save ref image (to remove black boarder
% created by movie normalize) -- this cropping may be unnecessary in the
% future.
%ref = ref(120:end-120, 120:end-120);
%imwrite(ref, 'ref2.tif');

%% mosaic.
mosaic_img = imread(fullfile(savedir, 'mosaic.tif'));
% resize to account for 4x upsampling
mosaic_img = imresize(mosaic_img, 0.25);
% resize to account for change in field size from 1.3 to 0.92
mosaic_img = imresize(mosaic_img, mosaic_scale_factor);
% cut off the edges to avoid any lines
mosaic_img = mosaic_img(4:end-3, 4:end-3, :);
% convert to gray scale image for dtf registration
mosaic_gray = sum(mosaic_img, 3); %rgb2gray(mosaic);
% zero buffer to make the same size as ref
mosaic_gray = img.zero_buffer(mosaic_gray, size(ref), [], ...
    mean(mosaic_gray(:)));
%figure; imshow(mosaic_gray, [0 255]);

% find the relative offsets
mosaic_offset = img.dftregistration(fft2(im2double(ref)), ...
    fft2(im2double(mosaic_gray)), 100);


% zero buffer and apply offsets to mosaic
%mosaic_offset(3:4) = [-2, 55];
mosaic_img = img.zero_buffer(mosaic_img, size(ref), ...
    [mosaic_offset(3), mosaic_offset(4)]);

%
f = figure; 
imshow(ref);
hold on;

%figure; hold on;
center = floor(size(ref) ./ 2);
colors = {'b' 'g' 'r'};

% load cone locations
cones = cone_mosaic.load_locs(subject);

% scale based on raster size change
cones(:, 1:2) = cones(:, 1:2) .* mosaic_scale_factor;
cones(:, 2) = max(cones(:, 2)) - cones(:, 2);

% zero array for coordinates of cones in ref image space
new_cone_coords = zeros(size(cones));
for c = 1:size(cones, 1)
    cone = cones(c, :);
    coneloc = [cone(1) + mosaic_offset(4) + center(1) - ...
        (max(cones(:, 1) / 2)) - 2,...
        cone(2) + mosaic_offset(3) + center(2) - (max(cones(:, 2) / 2))-1];
    
    plot(coneloc(1), coneloc(2), ...
        '.', 'color', colors{cone(3)}, 'markersize', 16);
    new_cone_coords(c, :) = [coneloc cone(3)];
end

mosaic_h = imshow(uint8(mosaic_img));
set(mosaic_h, 'AlphaData', 0.25);

save(fullfile(savedir, 'cone_coord_ref_img_space'), 'new_cone_coords');
plots.save_fig(fullfile(savedir, 'ref_img_w_conetypes'), f);