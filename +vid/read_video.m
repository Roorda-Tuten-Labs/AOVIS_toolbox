function vidFrames = read_video(video_file)

    % create a video reader object
    readerobj = VideoReader(video_file);
    % try to use the most up to date matlab way of reading in video
    if exist('VideoReader/readFrame') ~= 0
        frameIndex = 1;
        while hasFrame(readerobj);
            vidFrames(frameIndex).cdata = readFrame(readerobj);
            frameIndex = frameIndex + 1;
        end
        numFrames = frameIndex - 1;
    else % otherwise default to older method
        numFrames = get(readerobj, 'NumberOfFrames');
        t_vidFrames = read(readerobj);
        for frameIndex = 1:numFrames
            vidFrames(frameIndex).cdata = t_vidFrames(:, :, frameIndex);
        end
    end
    disp('-- finished reading --')
    
    % check if color is 3 dimensional
    if length(size(vidFrames(1).cdata)) > 2
        if size(vidFrames(1).cdata, 3) > 1
            for frameIndex = 1:numFrames
                vidFrames(frameIndex).cdata = ...
                    vidFrames(frameIndex).cdata(:, :, 1);
            end
        end
    end

    
end