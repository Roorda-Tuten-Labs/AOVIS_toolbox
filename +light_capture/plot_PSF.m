% ---- Plot PSFs ----

% --- General parameters
% pixels per degree
scaling = 2000; 
% in pixels; should correspond to number of pixels in AOSLO raster
imsize = 512;
%stimulus wavelength in microns
lamda = 543/1000;
% can otherwise read in hsws files.
diff_limited = 1;

pupil_sizes = [5.8, 6.4, 7.2];

%set up PSF parameters
field_size = imsize./scaling; %in degrees
%half the size of the cropped stimulus representation
halfwidth = 25; 


figure;
p = 1;
m = length(pupil_sizes);
n = 4;
for pupil_size = pupil_sizes
    for defocus = 0:0.025:0.075

        PSF = GeneratePSF(imsize, pupil_size, pupil_size, field_size * 60, ...
            lamda, diff_limited, defocus);
        subplot(m, n, p)
        imshow(PSF(228:286, 228:286), [0 max(PSF(:))])
        title([num2str(pupil_size) ' mm, ' num2str(defocus) ' D']);
        
        % diff_im = convolve(stim_im_orig, PSF);
        % stim_im_tmp = im2double(diff_im);
        p = p + 1;

    end
end