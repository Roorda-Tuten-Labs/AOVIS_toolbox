function [X_cross_loc, Y_cross_loc, framenums_withcross] = find_cross(filename)

import util.*

ir_cross = zeros(21, 21);
ir_cross(11,:)=1;ir_cross(:,11)=1;

IR    = 0;
Red   = 1;
Green = 2;

cross_num = IR;

if cross_num == IR;
    pixel = 255/255;
    
elseif cross_num == Red;
    pixel = 253/255;
    
elseif cross_num == Green;
    pixel = 251/255;
    
end

readerobj = VideoReader(filename);
vidFrames = read(readerobj);
startframe = 1; 
endframe = readerobj.NumberOfFrames; 

n = 1;

for framenum=startframe:endframe

    currentframe = im2double(vidFrames(:,:,:,framenum));
    currentframe = currentframe(:,:,1);
    currentframe = currentframe.*(currentframe==pixel);
    
    xcorr = normxcorr2f(ir_cross, currentframe);
    
    [not_used(framenum,1), Yr(framenum,1), Xr(framenum,1)] = util.max2D_RS(xcorr);

    if not_used(framenum,1) > 0.5
        Y(n,1)  = Yr(framenum,1);
        X(n,1)  = Xr(framenum,1);
        max_val = not_used(framenum,1);
        framenums_withcross(n,1) = framenum;
        n = n+1; 
    end
    
end

if (exist('X')) && (std(X) < 10) && std(Y) < 10

        X_cross_loc = round(mean([(X ( find( (X <= (mean(X)+std(X)/2) ) & ...
            (X >= (mean(X)-std(X)/2)) )) ) ]));
        
        Y_cross_loc = round(mean([(Y ( find( (Y <= (mean(Y)+std(Y)/2) ) & ...
            (Y >=(mean(Y)-std(Y)/2)) )) ) ]));

else
    errordlg('IR cross not found/not reliable, Record another movie');

end
