%This program will add movie frames together and generate an average image that has been normalized by the the number of frames 
%that have contributed to each pixel in the image. The result is that there
%are no intensity drop offs at the edges of the averaged image that would normally be casued by fewere frames contributing to those regions. 
%On the other hand, the edges of the frames are noisier since they comprose fewer averaged frames.

% You only need one copy of this program. You need to identify
% the folder that contains the avi files. It will add all avi files in the
% selected directory
%Austin Roorda October 17, 2007

pname = uigetdir;
a= dir([pname '/*.avi']);

[nummovies junk] = size(a);

for movienum = 1:nummovies
    
    fname = a(movienum).name

    AVIdetails=aviinfo([pname '/' fname]);

    sumframe=zeros(AVIdetails.Height,AVIdetails.Width);
    sumframebinary=ones(AVIdetails.Height,AVIdetails.Width);

    startframe = 1; 
    endframe = AVIdetails.NumFrames; %change this range to add any subset of frames
    %endframe=25;

    fprintf('Frames %g to %g are being co-added and saved to a tif file\n',startframe,endframe);

    for (framenum=startframe:endframe)
    currentframe = double(frame2im(aviread([pname '/' fname],framenum)));
    currentframebinary = im2bw(currentframe,1); %generate a binary image to locate the actual image pixels
    sumframe=sumframe+currentframe;
    sumframebinary = sumframebinary+currentframebinary; % generate an image to divide by the sum image to generate an average
    imshow(sumframe./max(max(sumframe)));
    drawnow;
    end
    name = [pname '/sumnorm_' fname '.tif']
    sumframenew = sumframe./sumframebinary;
    imshow(sumframenew/max(max(sumframenew)));drawnow;
    imwrite(sumframenew/max(max(sumframenew)),name,'tif','Compression','none');
end