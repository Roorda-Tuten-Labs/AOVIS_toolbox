function nice_axes(xlabelname, ylabelname, fontsize, ticksize, offsetaxes)
    % nice_axes(xlabelname, ylabelname, fontsize, ticksize, offsetaxes)
    % 
    if nargin < 3 || isempty(fontsize)
        fontsize = 14;
    end
    if nargin < 4 || isempty(ticksize)
        ticksize = 0.025;
    end    
    if nargin < 5
        offsetaxes = 1;
    end

    ylabel(ylabelname, 'FontSize', fontsize);
    xlabel(xlabelname, 'FontSize', fontsize);
    
    if offsetaxes
        try
            ax = gca;
            plots.offsetAxes(ax);
        catch ME
            disp(ME);
            disp(['offset axes did not run properly.' ...
            'does not work on older versions of matlab']);
        end
    end
    
    set(gca, 'FontSize', fontsize, 'TickLength', [ticksize ticksize], ...
        'tickdir', 'out', 'xcolor', [0 0 0], 'ycolor', [0 0 0], 'linewidth', 1.25);
    box off

    %whitebg(f, 'k');
end
