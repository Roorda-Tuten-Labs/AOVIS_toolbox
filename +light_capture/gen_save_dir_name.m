function savename = gen_save_dir_name(data, subdir)

    %create a place to save the figures
    save_dir = fullfile(pwd, subdir);
    if isdir(save_dir)==0
        mkdir(save_dir);
    end
    
    % set up save name for saving data and plots
    savename = [save_dir filesep() data.subject '_' ...
        num2str(data.scaling) 'pix_' num2str(data.pupil_size) 'pupil_' ...
        num2str(data.test_ecc) 'ecc'];
    if ~strcmp(data.subject, 'model')
        savename = [savename '_cind' num2str(data.center_cone_index)];
    end
end