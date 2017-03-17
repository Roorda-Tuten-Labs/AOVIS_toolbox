function arrow(x, y, linewidth)
    if nargin < 3
        linewidth = 1;
    end
    [figx, figy] = plots.dsxy2figxy(x, y);
    annotation('arrow', figx, figy, 'linewidth', linewidth);

end

