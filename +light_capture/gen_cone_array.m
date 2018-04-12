function [xi, yi, model_im, model_im_layers] = gen_cone_array(data)

% --- Set up array of cone light collecting apertures
% cone inner segment as a func of eccentricity
fwhm = light_capture.get_fwhm_curcio(data.test_ecc, data.scaling, ...
    data.proportion);

% convert FWHM to standard deviation of Gaussian
c = fwhm./2.35482; 

% size of 2D cone aperture (should be odd, ideally);
filtersize = 15; 
cone_aperture = fspecial('gaussian', filtersize, c);

% normalize Gaussian; can vary cone weight by varying 
% the "height" of the Gaussian
cone_aperture = cone_aperture ./ max(cone_aperture(:)); 

% demo x and y locations of cones near the location of stimulus
% delivery here; get this from the subject's mapped SML image

% Take cone density, make hexagon and then scale by image size
test_ecc_mm = data.test_ecc * 0.28;
cone_density = light_capture.curcio_cone_density(test_ecc_mm, 'mean', 'mm');
cone_spacing_mm = sqrt(sqrt(3) / (2 * cone_density));
cone_spacing = cone_spacing_mm * (1 / 0.28) * 60; % in arcmin

%center of the image: should be 256 if 512x512 image
center = data.imsize / 2; 
    
try
    % get the cones from a subject
    cones = cone_mosaic.load_locs(data.subject);
catch
    if ~strcmp(data.subject, 'model')
        warn(['Cone mosaic for ' data.subject ' could not be loaded.' ...
            ' Make sure that the mosaic is known to cone_mosaic.load_locs']);
    else
        cones = [];
    end
end
    
%hard-coded array of x and y locations of cones at this eccentricity 
% (8 pixel spacing at 1.5 degrees and 420 ppd)
if isempty(cones)
    if data.test_ecc == 1.5 && data.scaling == 420 && strcmp(data.subject, 'model')  
        xi = [256 252 260 248 264 252 260 256 256 240 272 244 268 264 248 244 ...
            268 248 264 240 272 240 272]';
        yi = [256 249 249 256 256 263 263 270 242 256 256 249 249 242 242 263 ...
            263 270 270 242 242 270 270]';
        
    else
        s2 = 0.5;
        x = [0 -s2 s2 -1 1 -s2 s2 -s2-1 s2+1 -s2-1 s2+1 0 1 -1 0 1 -1 -2 2]';
        y = [0 1 1 0 0 -1 -1 -1 -1 1 1 2 2 2 -2 -2 -2 0 0]';
        % scale by cone spacing at test_ecc, convert to deg, scale by
        % raster and shift the whole thing to the center of the image.
        xi = x * cone_spacing / 60 * data.scaling + center;
        yi = y * cone_spacing / 60 * data.scaling + center;
    end

% use real mosaic file!
else
    
    % data for 10001, 20053 & 20076 were collected at a pix/deg of 420, need to
    % convert the locations into new coordinate space.
    if strcmp(data.subject, '10001') || strcmp(data.subject, '20053') ||...
            strcmp(data.subject, '20076')
        cones(:, 1:2) = cones(:, 1:2) * (data.scaling / 420);
    end
    
    % select out a center cone of interest
    x_cone = cones(data.center_cone_index, 1);
    y_cone = cones(data.center_cone_index, 2);
    
    % find the 20 nearest neighbors
    [indexes, ~] = knnsearch(cones(:, 1:2), [x_cone y_cone], 'k', 21);
    
    % save this info for later analyses
    data.neighbor_indexes = indexes;
    
    % create an x, y list of cones
    xi = cones(indexes(2:end), 1);
    yi = cones(indexes(2:end), 2);
    xi = [x_cone; xi];
    yi = [y_cone; yi];

end

% center the patch of cones to avoid artifacts at edge of the image.
xdelta = center - xi(1);
ydelta = center - yi(1);
xi = xi + xdelta;
yi = yi + ydelta;

% do we need to round? Check below.
xi = round(xi); 
yi = round(yi);

%pre-allocate for cone aperture array
model_im_layers = zeros(data.imsize, data.imsize); 
for cone = 1:size(xi,1)
    %sometimes it is useful to keep each cone in a separate layer
    %so that one can make calculation of capture in each receptor more easily
    model_im_layers(yi(cone)-((filtersize-1)/2):yi(cone)+((filtersize-1)/2),...
                    xi(cone)-((filtersize-1)/2):xi(cone)+((filtersize-1)/2),...
                    cone) = cone_aperture;
end

% add layers of model_im together to create a "flat" model_im 
% (for other modeling purposes)
model_im = sum(model_im_layers,3);
