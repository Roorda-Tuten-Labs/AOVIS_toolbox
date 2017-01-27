% cut a video

start_frame = 120;
end_frame = 240;

try
    if ismac
        [fname, pathname, ~] = uigetfile('*.avi', 'Select video file', ...
            '.'); 
    elseif ispc
        [fname, pathname, ~] = uigetfile('*.avi', 'Select video file', ...
            '.');
    else
        [fname, pathname, ~] = uigetfile('*.avi', 'Select video file');
    end
catch
    [fname, pathname, ~] = uigetfile('*.avi', 'Select video file');
end
disp([pathname fname]);

reader = VideoReader([pathname fname]);
writer = VideoWriter([pathname fname(1:end-4) '_cut.avi'], 'Grayscale AVI');
writer.FrameRate = reader.FrameRate;
open(writer);

frame = 1;
while hasFrame(reader)
   img = readFrame(reader);
   if frame > start_frame && frame <= end_frame
       writeVideo(writer,img);
   end
   frame = frame + 1;
end

close(writer);