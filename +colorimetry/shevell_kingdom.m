clear;
primaries = 'bps';

% params for backgrounds
% lum   s     lm   
gray = [0.5 0.025 0.69];
red = [0.5 0.019 0.74];
green = [0.5 0.009 0.66];
blue = [0.5 0.0525 0.67];
yellow = [0.85 0.004 0.71];

purple = [0.5 0.05 0.71]; % purple

%target = [0.5 0.025 0.69]; % gray
%target = [0.85 0.004 0.71]; % yellow
target = yellow; %[0.5 0.05 0.71]; % purple

square_lum = target(1);
square_s = target(2); 
square_lm = target(3);


figure();
%axis square;
axis off;
box off;
set(gca, 'XTickLabel','', 'YTickLabel','');

square_mb = [square_lm square_s];
square_lms = MacBoyn2LMS(square_mb, square_lum);
square_rgb = LMS2RGB(square_lms, primaries);

%rectangle('Position', [0.0, 0.0, 1.0, 1.0], 'facecolor', square_rgb, ...
%    'edgecolor', 'none');
red_mb = [red(3) red(2)];
red_lms = MacBoyn2LMS(red_mb, red(1));
red_rgb = LMS2RGB(red_lms, primaries);
green_mb = [green(3) green(2)];
green_lms = MacBoyn2LMS(green_mb, green(1));
green_rgb = LMS2RGB(green_lms, primaries);

fsize = 150;

text(0.42, 0.5, 'i', 'color', green_rgb, 'fontsize', fsize);
text(0.50, 0.5, 'o', 'color', red_rgb, 'fontsize', fsize);
for i = 0:39
    c = mod(i, 2);

    if c > 0
    rectangle('Position', [0.0, 0 + i * 0.025, 1.0, 0.025], 'facecolor', square_rgb, ...
        'edgecolor', 'none');
    end
    
end


text(0.05, 0.5, 'v', 'color', red_rgb, 'fontsize', fsize);
text(0.2, 0.5, 'i', 'color', green_rgb, 'fontsize', fsize);
text(0.26, 0.5, 's', 'color', red_rgb, 'fontsize', fsize);

text(0.68, 0.5, 'n', 'color', green_rgb, 'fontsize', fsize);

colors = blue;
color = colors(1, :);
color_mb = [color(3) color(2)];
color_lms = MacBoyn2LMS(color_mb, color(1));
color_rgb = LMS2RGB(color_lms, primaries);
    
for i = 0:39
    c = mod(i, 2);

    if c < 1
    rectangle('Position', [0.0, 0 + i * 0.025, 1.0, 0.025], 'facecolor', color_rgb, ...
        'edgecolor', 'none');
    end
end
