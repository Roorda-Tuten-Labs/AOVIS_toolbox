function plot_multi_cone_FoS(exp_data, save_plots)
if nargin < 2
    save_plots = 0;
end

IDs = unique(exp_data.combination_id);
FoS = zeros(length(IDs), 1);

for id = 1:length(IDs)
    response = exp_data.answer(exp_data.combination_id == id);
    %intensities = exp_data.intensities(exp_data.combination_id == id);
    FoS(id, 1) = sum(response) / length(response);
    FoS(id, 2) = sqrt(FoS(id, 1) * (1 - FoS(id, 1)) / length(response));
end

nunique_cones = unique(exp_data.location_ids(:, 1));

fig1 = figure;
hold on;

single_cones = IDs <= max(nunique_cones);

errorbar(IDs(single_cones), FoS(single_cones, 1), FoS(single_cones, 2), ...
    FoS(single_cones, 2), 'bo', 'linewidth', 2.4)

errorbar(IDs(~single_cones), FoS(~single_cones, 1), FoS(~single_cones, 2), ...
    FoS(~single_cones, 2), 'ro', 'linewidth', 2.4)

xlim([1 length(IDs)])
plots.nice_axes('ID', 'frequency of seeing');
set(gca,'xtick', 1:3:length(IDs))

if save_plots
    videofolder = exp_data.videofolder(15:end);
    savename = fullfile(videofolder, 'multi_cone_FoS');
    plots.save_fig(savename, fig1, 1, 'eps');
end      