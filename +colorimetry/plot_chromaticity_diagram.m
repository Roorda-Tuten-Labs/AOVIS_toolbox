max_wv = 700;
primaries = 'roorda';

% Get cone fundamentals
fundamentals = 'konig';
if strcmp(fundamentals, 'stockman')
    cones = csvread('dat/stockman2deg.csv');
    lms = cones(:, 2:4);
    spectrum = cones(:, 1);
    
elseif strcmp(fundamentals, 'smith-pokorny')
    tmp_cie = csvread('dat/ciexyzjv.csv');
    % need to upsample with spline
    spectrum = min(tmp_cie(:, 1)):1:max(tmp_cie(:, 1));
    xyz = zeros(length(spectrum), 3);
    for i = 1:3
        cs = spline(tmp_cie(:, 1), tmp_cie(:, i+1));
        xyz(:, i) = ppval(cs, spectrum);
    end
    lms = xyz2lms(xyz')';
    %lms(:, 1) = lms(:, 1) ./ max(lms(:, 1));
    %lms(:, 2) = lms(:, 2) ./ max(lms(:, 2));
    %lms(:, 3) = lms(:, 3) ./ max(lms(:, 3));

elseif strcmp(fundamentals, 'konig')
    [lms, spectrum] = konig_fundamentals();
    lms = lms';
end
max_ind = find(spectrum == max_wv);
lms = lms(1:max_ind, :);

%Based off of Stockman cone spectral sensitivities and luminious efficiency function.
%lms = diag([0.689903, 0.348322, 0.0371597]') * lms';
%lms = lms';

% Get primaries
primaries = get_norm_primaries(primaries);
primary_spectrum = primaries(:, 1);
max_ind = find(primary_spectrum == max_wv);
primaries = primaries(1:max_ind, 2:4);

% Find MB chromaticity of primaries
min_wv = min(primary_spectrum);
min_ind = find(spectrum == min_wv);
lms = lms(min_ind:end, :); 

primary_lms = primaries' * lms;
if strcmp(fundamentals, 'stockman')
    [primary_mb, ~] = LMS2MacBoyn(primary_lms');
elseif strcmp(fundamentals, 'smith-pokorny')
    primary_mb = LMSToMacBoyn(primary_lms');
end

% Find the spectrum locus
if strcmp(fundamentals, 'stockman')
    [mb, ~] = LMS2MacBoyn(lms');
elseif strcmp(fundamentals, 'smith-pokorny')
    mb = LMSToMacBoyn(lms');
end

% Find chromaticity of background leak
bkgd_stim = csvread('dat/Roorda_lab_AO_stim_leak.csv');
bkgd_stim = bkgd_stim(1:max_ind, 2);
bkgd_lms = bkgd_stim' * lms;

if strcmp(fundamentals, 'stockman')
    [leak_mb, ~] = LMS2MacBoyn(bkgd_lms');
elseif strcmp(fundamentals, 'smith-pokorny')
    leak_mb = LMSToMacBoyn(bkgd_lms');
end

%[leak_mb, ~] = LMS2MacBoyn(bkgd_lms'); 

plot(mb(1, :), mb(2, :), 'k-', 'LineWidth', 2); hold on;
plot([mb(1, 1) mb(1, end)], [mb(2, 1) mb(2, end)], 'k-', 'LineWidth', 2);

% Find the location of EE white
EE_lms = sum(lms, 1);
if strcmp(fundamentals, 'stockman')
    [EE_mb, ~] = LMS2MacBoyn(EE_lms');
elseif strcmp(fundamentals, 'smith-pokorny')
    EE_mb = LMSToMacBoyn(EE_lms');
end
%[EE_mb, ~] = LMS2MacBoyn(EE_lms');

% Find the locations of the unique hues
u_g_ind = find(spectrum == 520);
u_y_ind = find(spectrum == 578);
u_b_ind = find(spectrum == 474);

u_g = mb(:, u_g_ind);
u_b = mb(:, u_b_ind);
u_y = mb(:, u_y_ind);

% Plot unique hues

plot([u_g(1) EE_mb(1)], [u_g(2) EE_mb(2)], 'g-');
plot([u_b(1) EE_mb(1)], [u_b(2) EE_mb(2)], 'b-');
plot([u_y(1) EE_mb(1)], [u_y(2) EE_mb(2)], '-', 'color', [0.8 0.8 0.3]);
plot([0.965 EE_mb(1)], [EE_mb(2) EE_mb(2)], 'r-');

% Plot gamut
plot([primary_mb(1, :) primary_mb(1, 1)], ...
    [primary_mb(2, :) primary_mb(2, 1)], 'k');

% Plot EEW
plot(EE_mb(1), EE_mb(2), 'k+', 'markersize', 15);

% Plot stimulus leak (543 nm)
plot(leak_mb(1), leak_mb(2), 'kx', 'markersize', 15);

xlabel('L/(L+M)', 'fontsize', 26);
ylabel('S/(L+M)', 'fontsize', 26);

xlim([0.5 1.0])
ylim([-0.02 0.21])

box off;
set(gca, 'FontSize', 26, 'TickLength', [0.03 0.03], ...
        'tickdir', 'out', 'Xtick', 0.4:0.1:1, 'Ytick', 0:0.1:0.35)
