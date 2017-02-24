clear;

luminance_b = 0.33;
luminance_w = 0.33;
delta_l = 0.017;

blue_s = 0.07;
blue_l = 0.65;

white_s = 0.025;
white_l = 0.689;

%%% top rectangle
bkgd_mb = [blue_l blue_s];

lms = MacBoyn2LMS(bkgd_mb, luminance_b);

rgb = LMS2RGB(lms);

figure();
axis square;
box off;
set(gca, 'XTickLabel','', 'YTickLabel','');

rectangle('Position', [0.0, 0.5, 1.0, 0.5], 'facecolor', rgb);

m_mb = [blue_l - delta_l blue_s];

lms = MacBoyn2LMS(m_mb, luminance_b);

rgb = LMS2RGB(lms);

rectangle('Position',[0.1, 0.6, 0.3, 0.3], 'facecolor', rgb, ...
    'edgecolor', 'none');


l_mb = [blue_l + delta_l blue_s];

lms = MacBoyn2LMS(l_mb, luminance_b);

rgb = LMS2RGB(lms);

rectangle('Position',[0.6, 0.6, 0.3, 0.3], 'facecolor', rgb, ...
    'edgecolor', 'none');


%%% bottom rectangle
bkgd_mb = [white_l white_s];
lms = MacBoyn2LMS(bkgd_mb, luminance_w);
rgb = LMS2RGB(lms);

rectangle('Position', [0.0, 0.0, 1.0, 0.5], 'facecolor', rgb);

m_mb = [white_l - delta_l white_s];
lms = MacBoyn2LMS(m_mb, luminance_w);
rgb = LMS2RGB(lms);

rectangle('Position',[0.1, 0.1, 0.3, 0.3], 'facecolor', rgb, ...
    'edgecolor', 'none');


l_mb = [white_l + delta_l white_s];
lms = MacBoyn2LMS(l_mb, luminance_w);
rgb = LMS2RGB(lms);

rectangle('Position',[0.6, 0.1, 0.3, 0.3], 'facecolor', rgb, ...
    'edgecolor', 'none');
