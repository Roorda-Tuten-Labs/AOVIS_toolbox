function save_fig(save_name, fig, transparent, file_type)
    % save_fig(save_name, fig, transparent, file_type)
    % 
    if nargin < 3 || isempty(transparent)
        transparent = 1;
    end
    if nargin < 4
        file_type = 'pdf';
    end
    % make sure save dir exists
    dirname = fileparts(save_name);
    util.check_for_dir(dirname);
    
    % -m2 magnify 2x for good resolution
    if transparent
        set(gca, 'Color', 'none'); 
        %export_fig(save_name, ['-' file_type], '-m2', '-transparent', fig);
    end
    if strcmp(file_type, 'svg')
        print(fig, save_name, '-dsvg', '-r300', '-painters')
    elseif strcmp(file_type, 'pdf')
        figpos = get(fig, 'pos');
        figwidth = figpos(3);
        figheight = figpos(4);
        if figwidth > 625 || figheight > 750
            % if the figure is larger than the size of a figure, use best
            % fit to preserve the aspect ratio, while fitting on a single
            % page.
            print(fig, save_name, '-dpdf', '-bestfit');
        else
            print(fig, save_name, '-dpdf');
        end
    else
        print(fig, save_name, ['-d' file_type], '-r300', '-painters')
    end
    
end
    