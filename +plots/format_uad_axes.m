function format_uad_axes(boundaries, labels, title_text, fontsize)
    % format_uad_axes(boundaries, labels, title_text, fontsize)
    %
    
    if nargin < 1 || isempty(boundaries)
        boundaries = true;
    end
    if nargin < 2 || isempty(labels)
        labels = true;
    end
    if nargin < 3 || isempty(title_text)
        title_text = '';
    end
    if nargin < 4
        fontsize = 14;
    end

    hold on;

    % add tick marks
    for ii = 0.25:0.25:1
        plot([-1 1], [0 0], 'k-', 'linewidth', 2);
        plot([0 0], [-1 1], 'k-', 'linewidth', 2);
        plot([-0.04 0.04], [ii ii], 'k-', 'linewidth', 2);
        plot([-0.04 0.04], [-1 * ii -1 * ii], 'k-', 'linewidth', 2);
        plot([ii ii], [-0.03 0.03], 'k-', 'linewidth', 2);
        plot([-1 * ii -1 * ii], [-0.03 0.03], 'k-', 'linewidth', 2); 
    end

    % add diamond boundaries
    if boundaries
        plot([1 0], [0 1], 'k--', 'linewidth', 2);
        plot([0 -1], [1, 0], 'k--', 'linewidth', 2);
        plot([-1 0], [0, -1], 'k--', 'linewidth', 2);
        plot([0 1], [-1 0], 'k--', 'linewidth', 2);
    end

    if labels
        text(1.05, -0.18, 'yellow', 'FontSize', fontsize, 'rotation', 90);
        text(-1.08, -0.1, 'blue', 'FontSize', fontsize, 'rotation', 90);
        text(-0.145, 1.08, 'green', 'FontSize', fontsize);
        text(-0.075, -1.08, 'red', 'FontSize', fontsize);
    end

    if ~strcmp(title_text, '')
        text( -0.7, 1.26, title_text, 'FontSize', fontsize);
    end

    axis square;
    set(gca,'color','none')
    set(gca,'visible','off')
    set(gca,'ytick',[],'xtick',[]);
    xlim([-1 1]);
    ylim([-1 1]);
end