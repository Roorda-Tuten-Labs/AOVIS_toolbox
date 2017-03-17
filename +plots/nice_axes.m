function nice_axes(xlabelname, ylabelname, fontsize)
    % nice_axes(xlabelname, ylabelname, fontsize)
    % 
    if nargin < 3
        fontsize = 22;
    end

    ylabel(ylabelname, 'FontSize', fontsize);
    xlabel(xlabelname, 'FontSize', fontsize);
    
    set(gca, 'FontSize', fontsize, 'TickLength', [0.03 0.03], ...
        'tickdir', 'out');
    box off

    %whitebg(f, 'k');
end
