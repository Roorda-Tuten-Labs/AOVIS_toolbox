function img2avi(path, fmt, out, framerate, frameorder)
% img2avi - Converts image sequences to avi of required frame rate. The
% images are supposed to be numbered. For example img_1.bmp, img_2.bmp ...
% img_99.bmp. The input fmt in that case would be img_*.bmp. The function 
% would sequenced according to the '*'  
%
% Syntax: img2avi(path,fmt,out,framerate)
%
% Inputs:
%     path - folder containing the image sequences
%     fmt - format of the images
%     out - name of the output video file
%     framerate - The framerate of the output video
%
% Example:
%     img2avi('imgfol','img_*.bmp','vid.avi',25)
%
%
% Original Author: Tamoghna Mitra
% Thermal & Flow engineering laboratory, bo Akademi University
% https://www.mathworks.com/matlabcentral/fileexchange/51274-convert-image-sequence-to-avi/content//img2avi.m
% June 2015

fils = dir([path '/' fmt]);

fmt2 = strrep(fmt, '*', '%d');

num = zeros(1,length(fils));

for i = 1:length(fils)
   
    num(i) = sscanf(fils(i).name, fmt2);
    
end

if nargin < 5
    [~, frameorder] = sort(num);
end

outVideo = VideoWriter(out);
outVideo.FrameRate = framerate;

open(outVideo);

for i = frameorder
    
   img =  imread([path '/' fils(i).name]);
    
   writeVideo(outVideo,img); 
    
end

close(outVideo);

end