clear;
primaries = 'bps';
% Used in disseration to demonstrate idea of color contrast
% (Albers).

% params for backgrounds
% lum   s     lm   
gray = [0.5 0.025 0.69];

blue = [0.5 0.0525 0.67];

%target = [0.5 0.025 0.69]; % gray
%target = [0.85 0.004 0.71]; % yellow

%red = [0.5 0.019 0.74];
%green = [0.5 0.009 0.66];
%target = [0.5 0.015 0.70]; % purple

red = [0.4 0.019 0.76];
green = [0.4 0.009 0.66];
target = [0.4 0.04 0.735]; % purple

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

colors = [red; green];
xs = [0.0 0.0 0.0 0.5];
ys = [0.0 0.5 0.5 0.5];
for i = 1:2
    color = colors(i, :);
    
    color_mb = [color(3) color(2)];
    color_lms = MacBoyn2LMS(color_mb, color(1));
    color_rgb = LMS2RGB(color_lms, primaries);

    rectangle('Position', [xs(i), ys(i), 0.5, 0.5], 'facecolor', color_rgb, ...
        'edgecolor', 'none');

    rectangle('Position', [xs(i) + 0.1875, ys(i) + 0.1875, 0.125, 0.125], ...
        'facecolor', square_rgb, 'edgecolor', 'none');

end
