function nice_axes(xlabelname, ylabelname, fontsize, ticksize, offsetaxes)
    % nice_axes(xlabelname, ylabelname, fontsize)
    % 
    if nargin < 3
        fontsize = 22;
    end
    if nargin < 4
        ticksize = 0.025;
    end    
    if nargin < 5
        offsetaxes = 1;
    end

    ylabel(ylabelname, 'FontSize', fontsize);
    xlabel(xlabelname, 'FontSize', fontsize);
    
    if offsetaxes
        ax = gca;
        plots.offsetAxes(ax);
    end
    
    set(gca, 'FontSize', fontsize, 'TickLength', [ticksize ticksize], ...
        'tickdir', 'out', 'xcolor', [0 0 0], 'ycolor', [0 0 0], 'linewidth', 2);
    box off

    %whitebg(f, 'k');
end
