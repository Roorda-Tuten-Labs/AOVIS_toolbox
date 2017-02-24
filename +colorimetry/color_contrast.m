clear;
primaries = 'bps';

% params for backgrounds
% lum   s     lm   
gray = [0.5 0.025 0.69];
red = [0.5 0.019 0.74];
green = [0.5 0.009 0.66];
blue = [0.5 0.0525 0.67];

%target = [0.5 0.025 0.69]; % gray
%target = [0.85 0.004 0.71]; % yellow
target = [0.5 0.05 0.71]; % purple

square_lum = target(1);
square_s = target(2); 
square_lm = target(3);


figure();
axis square;
axis off;
box off;
set(gca, 'XTickLabel','', 'YTickLabel','');

square_mb = [square_lm square_s];
square_lms = MacBoyn2LMS(square_mb, square_lum);
square_rgb = LMS2RGB(square_lms, primaries);

colors = [gray; red; green; blue];
xs = [0.0 0.5 0.0 0.5];
ys = [0.0 0.0 0.5 0.5];
for i = 1:4
    color = colors(i, :);
    
    color_mb = [color(3) color(2)];
    color_lms = MacBoyn2LMS(color_mb, color(1));
    color_rgb = LMS2RGB(color_lms, primaries);

    rectangle('Position', [xs(i), ys(i), 0.5, 0.5], 'facecolor', color_rgb, ...
        'edgecolor', 'none');

    rectangle('Position', [xs(i) + 0.125, ys(i) + 0.125, 0.25, 0.25], ...
        'facecolor', square_rgb, 'edgecolor', 'none');

end
