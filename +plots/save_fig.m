function save_fig(save_name, fig, transparent, file_type)
    % save_fig(save_name, fig, transparent, file_type)
    % 
    if nargin < 3 || isempty(transparent)
        transparent = 1;
    end
    if nargin < 4
        file_type = 'pdf';
    end
    % sometimes the save goes too fast and other functions haven't finished
    pause(0.25);
    
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
    array.check_for_dir(dirname);
    
    % set background to transparent
    if transparent
        set(gca, 'Color', 'none'); 
    end
    
    % ensure that the saved figure looks like the one on the plots
    set(fig, 'PaperPositionMode', 'auto');
    
    if strcmp(file_type, 'svg')
        print(fig, save_name, '-dsvg', '-r300', '-painters')
        
    elseif strcmp(file_type, 'pdf')
        fig.Renderer = 'Painters';
        set(fig,'Units', 'Inches');
        pos = get(fig, 'Position');
        pos(3) = pos(3) * 1.1;
        pos(4) = pos(4) * 1.1;
        set(fig,'PaperUnits', 'Inches', 'PaperSize',[pos(3), pos(4)]);
        print(fig, save_name, '-dpdf', '-r0');%, '-fillpage')        

    elseif strcmp(file_type, 'eps')
        print(fig, save_name, '-depsc')
    else
        print(fig, save_name, ['-d' file_type], '-r300', '-painters')
    end
    
end
    