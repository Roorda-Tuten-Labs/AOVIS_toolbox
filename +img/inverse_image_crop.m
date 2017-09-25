function old_coordinates_x_y = inverse_image_crop(img_orig, rect, ...
    new_coordinates)

% new_coordinates are now in row-col format and not in (x,y) coordinate format
size_original = size(img_orig);

[x, y] = meshgrid(1:size_original(1),1:size_original(2));

x_crop = imcrop(x, rect);
y_crop = imcrop(y, rect);

size_cropped = size(x_crop);

% change coordiantes
old_coordinates_row_col(:,2) = x_crop(sub2ind(size_cropped,...
    new_coordinates(:,1), new_coordinates(:,2)));
old_coordinates_row_col(:,1) = y_crop(sub2ind(size_cropped,...
    new_coordinates(:,1), new_coordinates(:,2)));

old_coordinates_x_y =  fliplr(old_coordinates_row_col);
