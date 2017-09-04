%%
first_frameN = 4;

spotsize = 3;
% force spot size to be odd.
if mod(spotsize, 2) == 0
    spotsize = spotsize + 1;
end

deltasize = (spotsize - 1) / 2;

xi = [256 252 260 248 264 252 260]';
yi = [256 249 249 256 256 263 263]';

cone_locs = [xi, yi];

cone_locs(:, 1) = cone_locs(:, 1) - (min(cone_locs(:, 1)) - deltasize - 1);
cone_locs(:, 2) = cone_locs(:, 2) - (min(cone_locs(:, 2)) - deltasize - 1);

% Find the furthest away points.
image_size = max(cone_locs(:));

%
figure;
subplot(6, 6, 1);

ncones = 7;
k = 3;
combos = combnk(1:ncones, k);
ncombos = length(combos);

for s = 1:ncombos
    stimulus = zeros(image_size, image_size);
    cones = combos(s, :);
    for n = cones
        x = cone_locs(n, 1);
        xs = x - deltasize:x + deltasize;   
        y = cone_locs(n, 2);
        ys = y - deltasize:y + deltasize;   
        stimulus(xs, ys) = 1;
    end
    subplot(6, 6, s);
    imshow(stimulus);
end

% if isdir(fullfile(pwd, 'tempStimulus')) == 0;
%     mkdir(fullfile(pwd, 'tempStimulus'));
%     cd(fullfile(pwd, 'tempStimulus'));
% else
%     cd(fullfile(pwd, 'tempStimulus'));
% end

% % Make cross in IR channel to record stimulus location
% ir_im0 = stim.create_cross_img(21, 5, true);
% 
% blank_im0 = zeros(10, 10);
% 
% imwrite(blank_im0, 'frame2.bmp');
% imwrite(ir_im0, 'frame3.bmp');
% 
% cd ..;
