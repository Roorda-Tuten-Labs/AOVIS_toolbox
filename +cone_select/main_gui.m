function [offsets_x_y, X_cross_loc, Y_cross_loc, CFG] = main_gui(tca, ...
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
            try
                offset_filename = CFG.last_offset_filename;
                load(offset_filename);
                disp(['Using offsets: ' offset_filename]);
            catch
                error(['CFG last offset file was not found' ...
                    'Tried to load ' CFG.last_offset_filename ...
                    '. Check if it was deleted.'])
            end

        case 'New offsets from old/new movie'

            % name of folder with offsets
            folder_name = fullfile(rootfolder, CFG.initials);

            % gen new offsets
            [offsets_x_y, X_cross_loc, Y_cross_loc, CFG] = ...
                cone_select.cone_select(tca, CFG, folder_name);


    end
    % save CFG with new params
    CFGname = CFG.filename;
    save(fullfile('Experiments', CFGname), 'CFG');    
end 