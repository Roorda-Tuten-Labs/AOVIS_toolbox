function plot_uad(dat, title_text, markersize, fontsize)
    %plot(dat, cone_index, ntrials)
    %
    % Should contain no zero (not seen) rows).

    % handle input args
    if nargin < 2
        title_text = '';
    end
    if nargin < 3
        markersize = 9;
    end
    if nargin < 4
        fontsize = 12;
    end
    
    % import plotting library
    import plots.*

    [ntrials, nscale] = size(dat);

    t_gr = zeros(1, ntrials);
    t_yb = zeros(1, ntrials);
    for trial = 1:ntrials
        % color vector from given trial
        t_cone = dat(trial, :);
        
        % convert numbers to red, green, blue, yellow, white
        red = sum(t_cone == 1);
        green = sum(t_cone == 2);
        blue = sum(t_cone == 3);
        yellow = sum(t_cone == 4);
        white = sum(t_cone == 5);
        total = red + green + blue + yellow + white;
        
        % check for errors
        if total ~= nscale && total ~= 0
            error('Color values not computed properly. Must sum to Nscale');
        end
        t_gr(1, trial) = (green - red) / nscale;
        t_yb(1, trial) = (yellow - blue) / nscale;
    end
    
    gr = mean(t_gr);
    gr_sem = std(t_gr) / sqrt(ntrials);
    yb = mean(t_yb);
    yb_sem = std(t_yb) / sqrt(ntrials);

    h = plots.errorbarxy(yb, gr, yb_sem, gr_sem,{'ko', 'k', 'k'});
    plots.format_uad_axes(true, true, title_text, fontsize);
    
    set(h.hMain, 'MarkerSize', markersize);
    
end