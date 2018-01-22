function [offsets_x_y, X_cross_loc, Y_cross_loc, CFG] = cone_select(tca_offsets,...
    CFG, folder_name)
% Select cones either automatically [not working] or manually. This is
% called by main routine.
%
% USAGE
% [offsets_x_y, X_cross_loc, Y_cross_loc] = cone_select(tca_offsets,...
%    CFG, folder_name)            
%
% 
%

%open movie
%find the most recent movie saved in the subject initials folder.
[filename, videopath] = uigetfile('*.*',...
                    'Pick Stabilized Movie or SumFrame to analyze',...
                 folder_name);
datetime_format = strrep(strrep(strrep(datestr(now),'-',''),' ','x'),':','');
if strcmp(filename(end-3:end),'.tif')
    % if loading in an already stabilized image.
    img_s = im2double(imread([videopath, filename], 'tif'));
    % xy locations stored at end of the file name.
    X_cross_loc = str2num(filename(end-10:end-8));
    Y_cross_loc = str2num(filename(end-6:end-4));
   
elseif strcmp(filename(end-3:end),'.avi')
    % otherwise find crosses fresh
    [X_cross_loc, Y_cross_loc, framenums_withcross] = vid.find_cross(...
        [videopath, filename]);
    if ~isnan(X_cross_loc) && ~isnan(Y_cross_loc)
        % then if crosses are found, produce stabilized movie (sumnorm)
        img_s = vid.sumframe_from_stabilized_movie(videopath, filename, ...
            framenums_withcross, X_cross_loc, Y_cross_loc);
    else
        offsets_x_y = NaN;
        disp('X,Y cross locations were not found. Try another video.');
        return
    end
end

% To be safe, lets use 75% of the max allowed offsets.
% Old system used to be 32 width by 64 height
max_ROI_width  = 64 * 0.75;
max_ROI_height = 32 * 0.75;

% use TCA offsets when finding location of interest on retina
% we are applying TCA opposite to the way necessary to correct for it. in
% effect we are undoing the effects of TCA so that we always be selecting
% cones that are in the center of the raster. otherwise, the TCA offsets
% could push the targeted cones towards the edges if it is large.
tca_x = tca_offsets(1, 1);
tca_y = tca_offsets(1, 2);

ROI = [(X_cross_loc - tca_x - max_ROI_width / 2), ...
       (Y_cross_loc - tca_y - max_ROI_height / 2), ...
       max_ROI_width, max_ROI_height];

ROI_search = [(X_cross_loc - tca_x - 3 * max_ROI_width / 2), ...
       (Y_cross_loc - tca_y - 3 * max_ROI_height / 2), ...
       3 * max_ROI_width, 3 * max_ROI_height];

% cut the image down to speed up search   
img_crop = imcrop(img_s, ROI_search);
[m, n] = size(img_crop);
rect_x = floor((n/2) - ROI(3)/2);
rect_y = floor((m/2) - ROI(4)/2);
rect_h = floor(ROI(4));
rect_w = floor(ROI(3));
rect_position = [rect_x rect_y rect_w rect_h];

rect_position_old = NaN;

choice = questdlg('Register with previous cone selection ?', ...
 'Matching cone selection', ...
 'Yes','No, Fresh trial','Yes');
 
if strcmpi(choice,'YES')
    [filename_old, path_old] = uigetfile('*.*',...
        'Pick Old Stabilized SumFrame to register', folder_name);
    
    img_old = im2double(imread([path_old filename_old]));
    X_cross_loc_old = str2num(filename_old(end-10:end-8));
    Y_cross_loc_old = str2num(filename_old(end-6:end-4));
    ROI_search_old  = [(X_cross_loc_old + tca_x - 3*max_ROI_width/2), ...
                       (Y_cross_loc_old + tca_y - 3*max_ROI_height/2),...
                       3*max_ROI_width,3*max_ROI_height];
    
    img_old_crop = imcrop(img_old,ROI_search_old);
    [output, ~] = dftregistration(fft2(img_crop),fft2(img_old_crop),5);
  
    row_max_loc = output(4);
    col_max_loc = output(3);
    rect_position_old = [rect_x+row_max_loc rect_y+col_max_loc rect_w rect_h];
    
end

% Find cones with either auto or manual method
%if strcmpi(CFG.cone_selection_method,'manual')
    
fighandle = [];
try
    fighandle = cone_mosaic.add_cone_types_to_selection_img(CFG.initials, img_s, ...
        [X_cross_loc, Y_cross_loc]);    
    % save the ouput plot as an svg file
    savename = [videopath, (filename(1:end-4)), 'target_loc_' datetime_format];
    plots.save_fig(savename, fighandle, [], 'svg');
catch
    disp('Warning: Could not run add_cone_types_to_selection_img')
end

% This is the only routine used.
[img_map, offset_cropped] = cone_select.manual_cone_select(img_crop,...
    rect_position, rect_position_old);    

if ~isempty(fighandle)
    close(fighandle)
end

% else %strcmpi(CFG.cone_selection_method,'auto')
%     % !!
%     % !! This does not work. It is never used !!
%     % !!       
%     error('Auto method is not implemented. Please redo and select manual.')
%     %[img_map, offset_cropped] = cone_select.auto_cone_select(img_crop,...
%     %    rect_position);
%      
% end

% Selected cones
selected_cones_filename = [videopath, (filename(1:end-4)), 'selected_cones_' ...
    datetime_format '.png'];

imwrite(img_map, selected_cones_filename, 'png');

offsets_x_y = img.inverse_image_crop(img_s, ROI_search, fliplr(offset_cropped));

%%% Save offsets
% check for dir, name and save offsets for later
offset_filename = fullfile(videopath, [CFG.initials, '_offsets_',...
                   strrep(strrep(strrep(datestr(now),'-',''),...
                   ' ','x'),':',''), '.mat']);       
CFG.last_offset_filename = offset_filename;

save(offset_filename,'offsets_x_y', 'X_cross_loc', 'Y_cross_loc', ...
     'tca_offsets');
