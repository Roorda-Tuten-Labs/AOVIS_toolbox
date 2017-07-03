function plot_light_capture(data, savename)

    f2 = figure; hold on;
    axis square
    xlabel('Defocus (D)')
    ylabel('Proportion incident light captured')
    set(gca, 'TickDir', 'out', 'XTick', 0:0.05:0.25)

    %first plot errorbars and light capture in central cone
    errorbar(data.def, mean(data.per_cone_int(:,:,1),2), ...
        std(data.per_cone_int(:,:,1),0,2), ...
        'LineStyle', 'none', 'Color', 'k')
    h1 = plot(data.def, mean(data.per_cone_int(:,:,1),2), 'ro', ...
        'MarkerSize', 4, 'MarkerFaceColor', 'r');

    % next plot summed capture from neighboring ring
    h2 = plot(data.def, sum(mean(data.per_cone_int(:,:,2:7),2),3), 'ko', ...
        'MarkerSize', 4, 'MarkerFaceColor', 'k');

    % next plot average individual neighboring cone;
    h3 = plot(data.def, mean(mean(data.per_cone_int(:,:,2:7),2),3), 'ko',...
        'MarkerSize', 4, 'MarkerFaceColor', 'w');

    % next plot single nearest individual neighboring cone;
    h4 = plot(data.def, mean(mean(data.per_cone_int(:,:,2),2),3), 'k.',...
        'MarkerSize', 4, 'MarkerFaceColor', 'w');

    legend([h1 h2 h3 h4], {'Center (targeted) cone', 'Surrounding ring (n = 6)', ...
        'Neighboring cone (n = 1)', 'Nearest Neighbor'}, 'Location', 'NorthEast')

    % title(['Test eccentricity: ' num2str(test_ecc) ' degrees; ...
    % frame-to-frame jitter: ' num2str(delivery_error) ' arcmin; numJitter: ' ...
    % num2str(numSim)], 'FontSize', 10)
    xlim([-0.005 max(data.def)+0.005])
    ylim([0 1])

    %figure saving
    print(f2,'-dpsc2', [savename 'light_cap.eps']);