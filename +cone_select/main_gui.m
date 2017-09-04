function [offsets_x_y, X_cross_loc, Y_cross_loc] = main_gui(tca, ...
    rootfolder, CFG)
    %    [offsets_x_y, X_cross_loc, Y_cross_loc] = main_gui(tca, 
    %                                                   rootfolder, CFG)
    %
    %
    %

    % get user input about cone locations
    choice = questdlg('Would you like to use last offsets', ...
         'New or repeat', ...
         'Repeat previous experiment','New offsets from old/new movie',...
         'Repeat previous experiment'); 
    % last one repeated b/c it is default option

    % based on input do one of two things:
    switch choice
        case 'Repeat previous experiment'
            listing_offset_dir = dir(fullfile('.', ...
                                              'color_naming_offsets', '*.mat'));
            offset_filename = fullfile('.', 'color_naming_offsets', ...
                               listing_offset_dir(find(datenum(...
                                   {listing_offset_dir(:).date}) == max(max(...
                                       datenum({listing_offset_dir(:).date}))))).name);
            load(offset_filename); 

        case 'New offsets from old/new movie'

            % name of folder with offsets
            folder_name = fullfile(rootfolder, CFG.initials);

            % gen new offsets
            [offsets_x_y, X_cross_loc, Y_cross_loc] = cone_select.cone_select(...
                tca, CFG.cone_selection, folder_name, CFG.initials);

            % check for dir, name and save offsets for later
            util.check_for_dir('color_naming_offsets')        
            offset_filename = fullfile('.', 'color_naming_offsets', ...
                               [CFG.initials, '_offsets_',...
                               strrep(strrep(strrep(datestr(now),'-',''),...
                               ' ','x'),':',''), '.mat']);                                       
            save(offset_filename,'offsets_x_y', 'X_cross_loc', 'Y_cross_loc', ...
                 'tca');
    end
end 