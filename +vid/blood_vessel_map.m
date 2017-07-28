
% This program will add movie frames together and generate an average image 
% that has been normalized by the the number of frames that have 
% contributed to each pixel in the image. 

% pick a file.
[fname, pname]  = uigetfile('*.avi', 'Pick a video to analyze');

% read the file into memory
video_file = fullfile(pname, fname);
vidFrames = vid.read_video(video_file);

vid_height = size(vidFrames(1).cdata, 1);
vid_width = size(vidFrames(1).cdata, 2);

nframes = size(vidFrames, 2);
vid_mat = zeros(vid_height, vid_width, nframes);
division_mat = zeros(vid_height, vid_height, nframes);

for frame = 1:nframes
    
    vid_mat(:, :, frame) = vidFrames(frame).cdata;
    if frame > 1
        division_mat(:, :, frame) = ...
            vidFrames(frame - 1).cdata(:, :) ./ ...
            vidFrames(frame).cdata(:, :);
    end
end
mean_img = mean(division_mat, 3);
std_img = std(division_mat, [], 3);

figure;
imshow(mean_img, [0 max(mean_img(:))]);

figure
imshow(std_img);%, [0 max(std_img(:))]);

name = fullfile(pname, ['mean_' fname '.tif']);
imwrite(mean_img, name, 'tif', 'Compression', 'none');

name = fullfile(pname, ['std_' fname '.tif']);
imwrite(std_img, name, 'tif', 'Compression', 'none');
