function plot_uad(dat, title_text, markersize, fontsize, format_axes)
    % plot_uad(dat, title_text, markersize, fontsize, format_axes)
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
    if nargin < 5
        format_axes = 1;
    end
    if nargin < 6
        % 6 here is assumed to be max.
        max_sat_val = 6;
    end
    
    % import plotting library
    import plots.*

    [ntrials, nscale] = size(dat);
    independent_saturation = 0;
    if mod(nscale, 2) == 0
        % i.e. is even in length (independent sat judgment)
        nscale = nscale - 1;
        independent_saturation = 1;
    end

    t_gr = zeros(1, ntrials);
    t_yb = zeros(1, ntrials);
    for trial = 1:ntrials
        
        % color vector from given trial
        t_cone = dat(trial, :);
        
        if independent_saturation            
            white = nscale  .* ((max_sat_val - t_cone(1)) ./ max_sat_val); 
            t_cone = t_cone(2:end);
        else
            white = sum(t_cone == 5);
        end
        
        % convert numbers to red, green, blue, yellow, white
        red = sum(t_cone == 1);
        green = sum(t_cone == 2);
        blue = sum(t_cone == 3);
        yellow = sum(t_cone == 4);
        
        if independent_saturation          
            nonwhite = 1 - (white / nscale);
            red = red .* nonwhite;
            green = green .* nonwhite;
            blue = blue .* nonwhite;
            yellow = yellow .* nonwhite;
        end
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

    if format_axes
        plots.format_uad_axes(true, true, title_text, fontsize);
    end
    hold on;
    h = plots.errorbarxy(yb, gr, yb_sem, gr_sem, {'ko', 'r', 'r'});
    
    h.hMain.LineWidth = 1.75;
    h.hMain.MarkerFaceColor = 'w';
    set(h.hMain, 'MarkerSize', markersize);
    
end