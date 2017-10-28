function format_uad_axes(boundaries, labels, title_text, fontsize, linewidth)
    % format_uad_axes(boundaries, labels, title_text, fontsize, linewidth)
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
    if nargin < 5
        linewidth = 1.25;
    end
    hold on;
    

    % add tick marks
    for ii = 0.25:0.25:1
        plot([-1 1], [0 0], 'k-', 'linewidth', linewidth);
        plot([0 0], [-1 1], 'k-', 'linewidth', linewidth);
        plot([-0.04 0.04], [ii ii], 'k-', 'linewidth', linewidth);
        plot([-0.04 0.04], [-1 * ii -1 * ii], 'k-', 'linewidth', linewidth);
        plot([ii ii], [-0.03 0.03], 'k-', 'linewidth', linewidth);
        plot([-1 * ii -1 * ii], [-0.03 0.03], 'k-', 'linewidth', ...
            linewidth); 
    end

    % add diamond boundaries
    if boundaries
        plot([1 0], [0 1], 'k--', 'linewidth', linewidth);
        plot([0 -1], [1, 0], 'k--', 'linewidth', linewidth);
        plot([-1 0], [0, -1], 'k--', 'linewidth', linewidth);
        plot([0 1], [-1 0], 'k--', 'linewidth', linewidth);
    end

    if labels
        text(1.05, 0, 'yellow', 'FontSize', fontsize, 'rotation', 90, ...
           'horizontalalignment', 'center',...
           'verticalalignment', 'middle');
        text(-1.08, 0, 'blue', 'FontSize', fontsize, 'rotation', 90, ...
           'horizontalalignment', 'center',...
           'verticalalignment', 'middle');
        text(0, 1.05, 'green', 'FontSize', fontsize, ...
           'horizontalalignment', 'center',...
           'verticalalignment', 'middle');
        text(0, -1.05, 'red', 'FontSize', fontsize, ...
           'horizontalalignment', 'center',...
           'verticalalignment', 'middle');
    end

    if ~strcmp(title_text, '')
        h = title(title_text, 'FontSize', fontsize, ...
            'fontweight', 'normal');
        P = get(h,'Position');
        text(P(1), P(2) + 0.15, title_text, 'FontSize', fontsize, ...
            'fontweight', 'normal', 'horizontalalignment', 'center');        
        %set(h,'Position',[P(1) P(2)+0.1 P(3)])        
    end

    axis square;
    set(gca,'color','none')
    set(gca,'visible','off')
    set(gca,'ytick',[],'xtick',[]);
    xlim([-1 1]);
    ylim([-1 1]);
end