usfac = 32;

[files, pathname]=uigetfile('*.avi','Select avi file(s) for TCA computation');  

vname = fullfile(pathname, files);
readerobj = VideoReader(vname);

frame1 = double(readFrame(readerobj));
frame2 = double(readFrame(readerobj));

[output Greg] = dftregistration(fft2(frame1), fft2(frame2), usfac);

imshow(real(ifft2(Greg)), [0 255]);