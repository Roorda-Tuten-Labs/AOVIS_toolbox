function save_fig(save_name, fig, transparent, file_type)
    % save_fig(save_name, fig, transparent, file_type)
    % 
    if nargin < 3 || isempty(transparent)
        transparent = 1;
    end
    if nargin < 4
        file_type = 'pdf';
    end
    
    % if an extension is provided at the end of save_name, save the file as
    % that type.
    extension = save_name(end-3:end);
    if strcmp(extension(1), '.') 
        f = extension(2:4);
        if strcmp(f, 'svg') || strcmp(f, 'pdf') || strcmp(f, 'jpg') || ...
                strcmp(f, 'png') || strcmp(f, 'eps')
            file_type = extension(2:4);
        end
    end
    
    % make sure save dir exists
    dirname = fileparts(save_name);
    util.check_for_dir(dirname);
    
    % set background to transparent
    if transparent
        set(gca, 'Color', 'none'); 
    end
    if strcmp(file_type, 'svg')
        print(fig, save_name, '-dsvg', '-r300', '-painters')
    elseif strcmp(file_type, 'pdf')
        figpos = get(fig, 'pos');
        figwidth = figpos(3);
        figheight = figpos(4);
        fig.Renderer = 'Painters';
        if figwidth > 610 || figheight > 750
            % if the figure is larger than the size of a figure, use best
            % fit to preserve the aspect ratio, while fitting on a single
            % page.
            print(fig, save_name, '-dpdf', '-bestfit');
            
        else
            print(fig, save_name, '-dpdf');

        end
    elseif strcmp(file_type, 'eps')
        print(fig, save_name, '-depsc')
    else
        print(fig, save_name, ['-d' file_type], '-r300', '-painters')
    end
    
end
    