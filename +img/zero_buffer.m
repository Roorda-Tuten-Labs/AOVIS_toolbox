function buffimg = zero_buffer(image, newsize, rowcol_offset, buffer_val)
    % buffimg = zero_buffer(image, newsize, xy_offset)
    %
    % INPUT
    % image: input image.
    % newsize:  row x column size of buffered image. must be larger than
    %       image.
    % rowcol_offset: position within buffer. Default is to center the image
    %       in the buffer.
    % buffer_val: optional. set the buffer to a value other than zero. 
    %
    % OUTPUT
    % buffimg: the original image with zero buffered edges.
    if nargin < 4
        buffer_val = 0;        
    end
    
    % find the center of the image
    center = floor(newsize ./ 2);
    if nargin < 3 || isempty(rowcol_offset)
        rowcol_offset = center;
    else
        % have to round to integers
        rowcol_offset = round(rowcol_offset);
        % apply offsets from center of image if they exist
        rowcol_offset = center + rowcol_offset;
    end
    
    % zero buffer image
    if ndims(image) == 2
        buffimg = zeros(newsize(1), newsize(2));
    elseif ndims(image) == 3
        buffimg = zeros(newsize(1), newsize(2), size(image, 3));
    else
        error('n dimensions must be 2 or 3.')
    end
    imgsize = size(image);
    
    % row# is even
    if mod(size(image, 1), 2) == 0
        rowinds = rowcol_offset(1) - floor(imgsize(1) / 2) + 1:...
            rowcol_offset(1) + floor(imgsize(1) / 2);
    else
        rowinds = rowcol_offset(1) - floor(imgsize(1) / 2):...
            rowcol_offset(1) + floor(imgsize(1) / 2);
    end
    % col# is even
    if mod(size(image, 2), 2) == 0
        colinds = rowcol_offset(2) - floor(imgsize(2) / 2) + 1:...
            rowcol_offset(2) + floor(imgsize(2) / 2);
    else
        colinds = rowcol_offset(2) - floor(imgsize(2) / 2):...
            rowcol_offset(2) + floor(imgsize(2) / 2);
    end
    
    if buffer_val > 0
        buffimg = buffimg + buffer_val;
    end
    
    % put image into row and column indices
    buffimg(rowinds, colinds, :) = image;
    
    % make sure that image + xy_offsets does not extend the image beyond
    % desired size.
    buffimg = buffimg(1:newsize(1), 1:newsize(2), :);
    
    
    
