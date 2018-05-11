stimsize = 30;
stimshape = 'square';
imsize = 512;
sigma = 15;

stim_im = light_capture.createStimulus(stimsize, stimshape, imsize);
delivery_blur = fspecial('gaussian', imsize+1, sigma); 
delivery_blur = delivery_blur./max(delivery_blur(:)); %normalize
%trim pixel here, see above; peak of trial blur should be at (256, 256)
delivery_blur(:,end) = []; 
delivery_blur(end,:) = []; 

% first test: convolve from Austin 1997
t = cputime;
austin_result = array.convolve(stim_im, delivery_blur);
austin_time = cputime - t

% second test: native matlab conv2 function
t = cputime;
conv2result = conv2(stim_im, delivery_blur, 'same');
conv2result = conv2result ./ max(max(conv2result));
matlab_time = cputime - t

% make sure return same result
figure;
imshow(stim_im);
figure;
imshow(delivery_blur);

figure;
imshow(austin_result);
figure;
imshow(conv2result);

disp(size(austin_result)); disp(size(conv2result));
diff = austin_result - conv2result;
disp(sum(sum(diff)));

