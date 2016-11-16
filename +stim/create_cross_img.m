function cross = create_cross_img(img_size, cross_size, decrement)
% cross = make_cross_img(img_size, cross_size_pix, decrement)
% 
% img_size: in pixels. Must be an odd number or size will be incremented by
% one to make it so.
% 
% cross_size: in pixels. Size of the cross. Also must be an odd number.
% 
% decrement: false (0), true (1). Decide whether the stimulus is a
% decrement from ones (i.e. IR channel) or an increment from zeros (for
% green or red channel). Default is true.
% 
% returns: img_size X img_size matrix with a cross centered.

if nargin < 3
    decrement = true;
end

% make sure image size is odd
if mod(img_size, 2) ==0
    img_size = img_size + 1;
end
% make sure cross size is odd
if mod(cross_size, 2) ==0
    cross_size = cross_size + 1;
end

middle = ceil(img_size / 2);
cross_loc = (1:cross_size) + middle;

if decrement
    cross = ones(img_size, img_size);
    cross(:, cross_loc) = 0;
    cross(cross_loc, :) = 0;
else
    cross = zeros(img_size, img_size);
    cross(:, cross_loc) = 1;
    cross(cross_loc, :) = 1;    
end
    
end