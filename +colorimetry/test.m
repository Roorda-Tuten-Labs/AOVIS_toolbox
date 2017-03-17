clear;

 % Equal energy white at a medium-low luminance
lms = [0.3 0.3 0.3]';
disp(lms);

% Convert to MB space and keep luminance
[bkgd_mb, bkgd_lum] = LMS2MacBoyn(lms);

% Change to a test coordinate in MB, relative to background coordinate
test_LMS = MacBoyn2LMS([bkgd_mb(1) bkgd_mb(2)+ 0.02], bkgd_lum)

% Check RGB of background
bkgd_rgb = LMS2RGB(lms)

% Check RGB of test coordinate
rgb = LMS2RGB(test_LMS)

% Do a sanity check to make sure changes is only in S cone excitation.
lms1 = RGB2LMS(rgb)
