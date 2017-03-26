function delivery_err = find_error(video_dir, cross_size_pix, ...
    xcorr_thresh, cross_channel, print_info)
% Find delivery errors for all videos in a directory
% 
% USAGE
% delivery_err = find_delivery_error(video_dir, cross_size_pix, ...
%    xcorr_thresh, print_output)
%
% INPUT
% video_dir:        directory containing videos to analyze. if nothing or
%                   an empty string is passed, the user will be prompted to
%                   select a directory.
% cross_size_pix:   size of the cross used in cross correlation, specified
%                   in pixels. Default = 17.
% xcorr_thresh:     threshold for finding a cross. Default = 0.5.
% cross_channel:    the crosses from each channel are encoded with a unique 
%                   value. select the cross pixel value for the channel of
%                   interest. this will be used below to binarize the image
%                   and improve the detection algorithm. Defaul = ir.
% print_info:       0 or 1. Decide to print out information about videos and
%                   analysis. Default = 0.
%
% OUTPUT
% delivery_err:     an n by 4 matrix. n=number of videos. columns are 
%                   organized as follows: [video #, frame, x location, y
%                   location]
%

    
% ----- Params -----
if nargin < 1
    video_dir = '';
end
if nargin < 2
    cross_size_pix = 17;
end
if nargin < 3
    xcorr_thresh = 0.5;
end
if nargin < 4
    cross_channel = 'ir';
end
if nargin < 5
    print_info = 0;
end
% ------------------

% if video_dir is not set or is empty ask user to select directory
if isempty(video_dir)
    title = 'select directory';
    if ismac
        video_dir = uigetdir('/Volumes/lyle/Video_Files', title); 
    elseif ispc
        video_dir = uigetfile('\D:\\Video_Files\', title);
    else
        video_dir = uigetfile('', title);
    end
end
if print_info
    disp(video_dir);
end

% get a list of all files in video directory. this includes other files
% that we are not interested in. we will have to skip those in the loop
% below.
list_of_files = dir(video_dir);

delivery_err = [];
nfiles = size(list_of_files, 1);
analyzed_file_count = 0;
for n = 1:nfiles    
    fname = list_of_files(n).name;
    % select only stabilized videos
    if size(fname, 2) > 14
        if strcmpi(fname(end-14:end), '_stabilized.avi')
            % find x/y locations in each frame of video
            videopath = [video_dir filesep fname];
            [x_loc, y_loc, frames_w_cross] = vid.find_cross(videopath, ...
                cross_size_pix, xcorr_thresh, false, false, cross_channel);
            
            % save data
            video_number = ones(length(x_loc), 1) * ...
                str2double(fname(end-17:end-15));
            delivery_err = [delivery_err;  video_number, frames_w_cross, ...
                x_loc, y_loc]; %#ok<AGROW>
            
            % keep track of number of analyzed videos
            analyzed_file_count = analyzed_file_count + 1;
            
            % print out where we are in the analysis once in a while
            if print_info == 1 && analyzed_file_count > 0 && ...
                    mod(analyzed_file_count, 10) == 0
                disp([num2str(analyzed_file_count) ' videos analyzed'])
            end            
        end
    end
end
