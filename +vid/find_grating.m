function [X, Y, frames_w_grating, max_val] = find_grating(filename, grating_size_pix, ...
    orientation, xcorr_threshold, print_output, show_error_dlg)
% Find the center of a grating stimulus in a video frame by frame
%
% USAGE
% [X, Y, frames_w_grating, max_val] = find_grating(filename, grating_size_pix, ...
%    orientation, xcorr_threshold, print_output, show_error_dlg)
%    
%
% INPUT
% filename:             name of video file to read.
% grating_size_pix:     size of the grating in pixels (imported into main script)
%                           to use in correlation
% orientation:          loads the orientation of the stimulus on the retina
% xcorr_threshold:      threshold for detecting the grating, set to .5 default
% print_output:         0 or 1. Decide whether to print results, 1 = print
% show_error_dlg:       choose to show an error dialogue box with information
%                           for the user or not
% 
% OUTPUT
% X:          location of grating center in X, this will be a vector with 
%                       values for each frame where the grating center was found.
% Y:          location of grating center in Y. Same as above.
% frames_w_grating:       array containing frame numbers that contained an grating.
% max_val:          maximum correlation value between image and stimulus.


import util.*

if nargin < 2 %setting default params
    grating_size_pix = 10;
end
if nargin < 3
    orientation = 0;
end
if nargin < 4
    xcorr_threshold = 0.5; %.5 default
end
if nargin < 5
    print_output = 0;
end
if nargin < 6
    show_error_dlg = 0;
end


% generate a grating to scale of size presented
grating = ones(5,5);
grating([1 3 5], :, 1) = 0;
% resize
scale = grating_size_pix;
stimGrating = imresize(grating, scale, 'nearest');
% mask
squareMask = ones(size(stimGrating));
% pad
stimGrating = padarray(stimGrating, [1 1], 1, 'both');
squareMask = padarray(squareMask, [1 1], 1, 'both');
% rotate for each trial
stimGrating = imrotate(stimGrating,orientation,'bicubic', 'loose');
squareMask = imrotate(squareMask,orientation,'bicubic', 'loose');
stimGrating(squareMask < 0.05)=1;
% recolor
stimGrating = 1-stimGrating;

try
    % create video reader object
    reader = VideoReader(filename);
    
catch ME
    disp(filename);
    rethrow(ME);
    
end

frameN = 1;
n = 1;

while hasFrame(reader)  
    
    % select the current frame
    currentframe = readFrame(reader);
    
    % convert to a double (necessary for cross corr)
    currentframe = im2double(currentframe(:, :, 1));
    
    % change the background values to 0
    currentframe(currentframe==0) = [1];
    
    % invert the image
    currentframe = 1 - currentframe;
    
    % do the cross correlation, calls script to find largest values in each
    % row & column
    xcorr = imfilter(currentframe, stimGrating)./sum(stimGrating(:));
    % find the position of highest correlation
    [corr, Yr, Xr] = array.max2D_RS(xcorr);

    % check if corr was above threshold
    if corr > xcorr_threshold
        Y(n, 1)  = Yr;
        X(n, 1)  = Xr;
        max_val(n,1) = corr;
        frames_w_grating(n, 1) = frameN;
        n = n+1; 
    end
    
    % increment frame number
    frameN = frameN + 1;
end

% create variables with the locations
if exist('X', 'var') && exist('Y', 'var')
    if print_output == 1 % print
        disp(X); disp(std(X))
        disp(Y); disp(std(Y))

    end
else
    % in the case where E was not found in any frames, return nan values
    X = nan;
    Y = nan;
    max_val = corr;
    frames_w_grating(n, 1) = frameN;
    if show_error_dlg
        errordlg('IR E loc not found', 'Record another movie.');
    end
end