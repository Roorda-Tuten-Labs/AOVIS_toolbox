function save_fig(save_name, fig, transparent, file_type)
    % save_fig(save_name, fig, transparent, file_type)
    % 
    if nargin < 3 || isempty(transparent)
        transparent = 1;
    end
    if nargin < 4
        file_type = 'svg';
    end
    % make sure save dir exists
    dirname = fileparts(save_name);
    util.check_for_dir(dirname);
    
    % -m2 magnify 2x for good resolution
    if transparent
        set(gca, 'Color', 'none'); 
        %export_fig(save_name, ['-' file_type], '-m2', '-transparent', fig);
    end
    print(fig, save_name, ['-d' file_type], '-r300', '-painters')
    
end
    