function [X_cross_loc, Y_cross_loc, framenums_withcross] = find_cross(filename, ...
    cross_size_pix, xcorr_threshold, print_output, return_mean_only)

import util.*

if nargin < 2
    cross_size_pix = 17;
end
if nargin < 3
    xcorr_threshold = 0.5;
end
if nargin < 4
    print_output = true;
end
if nargin < 5
    return_mean_only = true;
end

% generate a cross
ir_cross = zeros(cross_size_pix, cross_size_pix);
center_cross = ceil(cross_size_pix / 2);
ir_cross(center_cross,:)=1;ir_cross(:, center_cross) = 1;

% create video reader object
reader = VideoReader(filename);

n = 1;
framenum = 1;
while hasFrame(reader)  
    currentframe = readFrame(reader);
    currentframe = im2double(currentframe(:, :, 1));
    %currentframe = currentframe .* (currentframe==pixel);

    xcorr = normxcorr2f(ir_cross, currentframe);
    [not_used(framenum, 1), Yr(framenum,1), Xr(framenum,1)] = util.max2D_RS(xcorr);

    if not_used(framenum, 1) > xcorr_threshold
        Y(n,1)  = Yr(framenum,1);
        X(n,1)  = Xr(framenum,1);
        max_val = not_used(framenum,1);
        framenums_withcross(n,1) = framenum;
        n = n+1; 
    end

    framenum = framenum + 1;
    
end

if print_output
    disp(X); disp(std(X))
    disp(Y); disp(std(Y))
end

if return_mean_only
    if (exist('X')) && (std(X) < 10) && std(Y) < 10

            X_cross_loc = round(mean([(X ( find( (X <= (mean(X)+std(X)/2) ) & ...
                (X >= (mean(X)-std(X)/2)) )) ) ]));

            Y_cross_loc = round(mean([(Y ( find( (Y <= (mean(Y)+std(Y)/2) ) & ...
                (Y >=(mean(Y)-std(Y)/2)) )) ) ]));

    else
        errordlg('IR cross not found/not reliable, Record another movie');

    end
    
else
    if exist('X', 'var') && exist('Y', 'var')
        X_cross_loc = X;
        Y_cross_loc = Y;
    else
        X_cross_loc = nan;
        Y_cross_loc = nan;
        framenums_withcross = nan;
    end
end

