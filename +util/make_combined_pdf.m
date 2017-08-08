function make_combined_pdf(directory, save_name)
    % 
    % USAGE
    % make_combined_pdf(directory, save_name)
    %
        
    % save into correct directory
    save_name = fullfile(directory, save_name);
    
    % delete an old file if it exists
    if exist(save_name, 'file') == 2
        delete(save_name);
    end
    
    % get all of the pdf files in the directory
    tmp = dir(fullfile(directory, '*.pdf'));
    filenames = {};
    for ii = 1:length(tmp)
        filenames{ii} = fullfile(directory, tmp(ii).name); %#ok
    end
    util.append_pdfs(save_name, filenames{:});

    open(save_name);
    
end