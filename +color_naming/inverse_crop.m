function [old_coordinates] = [img, img_crop, rect, new_coordinates]


n_orig = size(img); n_crop = size(img_crop);

old_coordinates(1,:) = size(img,1) - size(img_crop,1) - 1 + new_coordinates(1,:) ;



