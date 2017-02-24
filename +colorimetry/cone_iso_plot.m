clear;
primaries = 'bps';
bottom = 'blue';

% params for backgrounds
% lum   s     lm   delta
orange = [0.55 0.005 0.725 1.05];
blue = [0.35 0.07 0.675 1.1015];
green = [0.6 0.01 0.675 1.07];

% white. the cone contrast is assumed from the bottom rectangle
% chosen above. do not set one here.
%     lum     s     lm
p1 = [0.556 0.025 0.689];

if strcmp(bottom, 'blue')
    p2 = blue;
elseif strcmp(bottom, 'green')
    p2 = green;
elseif strcmp(bottom, 'orange')
    p2 = orange;
end

delta_lm = p2(4);

bottom_lum = p2(1);
bottom_s = p2(2); 
bottom_lm = p2(3);

top_lum = p1(1);
top_s = p1(2);
top_lm = p1(3);

figure();
axis square;
axis off;
box off;
set(gca, 'XTickLabel','', 'YTickLabel','');


%%% bottom rectangle

bkgd_mb = [bottom_lm bottom_s];
% convert background mb values into LMS value
bkgd_lms = MacBoyn2LMS(bkgd_mb, bottom_lum);
% convert background lms into rgb values
rgb = LMS2RGB(bkgd_lms, primaries);
% add to plot
rectangle('Position', [0.0, 0.0, 1.0, 0.5], 'facecolor', rgb);

% start with background lms values
m_lms = bkgd_lms;
% increment M cone value by delta set above
m_lms(2) = bkgd_lms(2) * delta_lm;
% convert M iso into rgb value
rgb = LMS2RGB(m_lms, primaries);
% add to plot
rectangle('Position',[0.1, 0.1, 0.3, 0.3], 'facecolor', rgb, ...
    'edgecolor', 'none');

% follow the same steps as above for L cones
l_lms = bkgd_lms;
l_lms(1) = bkgd_lms(1) * delta_lm;
rgb = LMS2RGB(l_lms, primaries);

rectangle('Position',[0.6, 0.1, 0.3, 0.3], 'facecolor', rgb, ...
    'edgecolor', 'none');

%%% top rectangle
% same as bottom rectangle but using white background
bkgd_mb = [top_lm top_s];
bkgd_lms = MacBoyn2LMS(bkgd_mb, top_lum);
rgb = LMS2RGB(bkgd_lms, primaries);

% Reproduced rgb values of slightly pink background produced in
% original white background paper supp fig with leak, IR and
% projector. Uncomment to use. Otherwise, keep commented and set in
% parameters at the top of the script.
%rgb = [169 159 166]' ./ 255;
bkgd_lms = RGB2LMS(rgb);

rectangle('Position', [0.0, 0.5, 1.0, 0.5], 'facecolor', rgb);

m_lms = bkgd_lms;
m_lms(2) = bkgd_lms(2) * delta_lm;
rgb = LMS2RGB(m_lms, primaries);

rectangle('Position',[0.1, 0.6, 0.3, 0.3], 'facecolor', rgb, ...
    'edgecolor', 'none');

l_lms = bkgd_lms;
l_lms(1) = bkgd_lms(1) * delta_lm;
rgb = LMS2RGB(l_lms, primaries);

rectangle('Position',[0.6, 0.6, 0.3, 0.3], 'facecolor', rgb, ...
    'edgecolor', 'none');
