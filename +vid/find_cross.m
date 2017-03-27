function [X_cross_loc, Y_cross_loc, frames_w_cross] = find_cross(filename, ...
    cross_size_pix, xcorr_threshold, print_output, return_mean_only, ...
    cross_channel)
% Find cross in a video
%
% USAGE
% [X_cross_loc, Y_cross_loc, frames_w_cross] = find_cross(filename, ...
%    cross_size_pix, xcorr_threshold, print_output, return_mean_only, ...
%    cross_channel)
%
% INPUT
% filename:         name of video file to read.
% cross_size_pix:   size of the cross in pixels to use in cross
%                   correlation.
% xcorr_threshold:  threshold for detecting a cross. default = 0.6.
% print_output:     0 or 1. Decide whether to print results
% return_mean_only: 0 or 1. this routine will find the mean by excluding
%                   values that are greater than 1 STD from the mean.
% cross_channel:    the crosses from each channel are encoded with a unique 
%                   value. we select the cross pixel value for the channel 
%                   of interest. this will be used below to binarize the 
%                   image and improve the detection algorithm. Default =
%                   ir.
%
% OUTPUT
% X_cross_loc:      location of cross in X. If return_mean_only==0, this
%                   will be a vector with values for each frame where the
%                   cross was found.
% Y_cross_loc:      location of cross in Y. Same application of
%                   return_mean_only.
% frames_w_cross:   array containing frame numbers that contained a cross.
%


import util.*

if nargin < 2
    cross_size_pix = 17;
end
if nargin < 3
    xcorr_threshold = 0.6;
end
if nargin < 4
    print_output = true;
end
if nargin < 5
    return_mean_only = true;
end
if nargin < 6
    cross_channel = 'ir';
end

% select channel with ir cross and set appropriate cross_pixel_val
if strcmpi(cross_channel, 'ir');
        cross_pixel_val = 255/255;
elseif strcmpi(cross_channel, 'red');
        cross_pixel_val = 253/255;
elseif strcmpi(cross_channel, 'green');
        cross_pixel_val = 251/255;
else
    error('cross_channel must be set to ir, red or green')
end

% generate a cross
ir_cross = zeros(cross_size_pix, cross_size_pix);
center_cross = ceil(cross_size_pix / 2);
ir_cross(center_cross,:)=1;ir_cross(:, center_cross) = 1;

try
    % create video reader object
    reader = VideoReader(filename);
    
catch ME
    disp(filename);
    rethrow(ME);
    
end
n = 1;
frameN = 1;
while hasFrame(reader)  
    % select the current frame
    currentframe = readFrame(reader);
    
    % convert to a double (necessary for cross corr)
    currentframe = im2double(currentframe(:, :, 1));
    
    % select cross type and bianarize image based on type. this will
    % largely eliminate confusion with bright cones that otherwise might
    % look to the cross correlation like a cross
    currentframe = currentframe .* (currentframe==cross_pixel_val);

    % do the cross correlation
    xcorr = normxcorr2f(ir_cross, currentframe);
    
    % find the position of highest correlation
    [corr, Yr, Xr] = util.max2D_RS(xcorr);

    % check if corr was above threshold
    if corr > xcorr_threshold
        Y(n, 1)  = Yr;
        X(n, 1)  = Xr;
        %max_val = corr(frameN, 1);
        frames_w_cross(n, 1) = frameN;
        n = n+1; 
    end

    % increment frame number
    frameN = frameN + 1;
    
end

if print_output
    disp(X); disp(std(X))
    disp(Y); disp(std(Y))
end

if return_mean_only
    if exist('X', 'var') && std(X) < 10 && std(Y) < 10
        % compute mean of XY position from cross locations that fall within
        % one STD of the mean.
        X_cross_loc = round(mean(X(find((X <= (mean(X)+std(X) / 2)) & ...
            (X >= (mean(X) - std(X) / 2))))));

        Y_cross_loc = round(mean(Y(find((Y <= (mean(Y) + std(Y) / 2)) & ...
            (Y >=(mean(Y) - std(Y) / 2))))));

    else
        errordlg('IR cross not found/not reliable, Record another movie');

    end
    
else
    if exist('X', 'var') && exist('Y', 'var')
        X_cross_loc = X;
        Y_cross_loc = Y;
    else
        % in the case where a cross was not found in any frames, return nan
        % values
        X_cross_loc = nan;
        Y_cross_loc = nan;
        frames_w_cross = nan;
    end
end

