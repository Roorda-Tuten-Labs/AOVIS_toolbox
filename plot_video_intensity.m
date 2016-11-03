function [] = plot_video_intensity()
    % plot_video_intensity()
    % -------------------------------------
    %
    % Select a video from file. Video is read in and the mean intensity of
    % each frame is plotted alongside the video. The user can then toggle
    % the frame number with the left and right arrow keys.
    %
    % Useful for bleaching experiments where determining mean intensity and
    % the first useable frame are important.
    %

    % open folder into default location. if it does not exist open current
    % directory.
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

    % create a video reader object
    readerobj = VideoReader([pathname fname]);
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
        

    % precompute mean intensity for each frame
    mean_int = zeros(1, numFrames);
    for frameIndex = 1 : numFrames
        mean_int(frameIndex) = mean(mean(vidFrames(frameIndex).cdata));
    end

    % create a figure object
    S.fh = figure('units','pixels',...
                  'position',[100, 100, 1300, 700],...
                  'menubar','none',...
                  'name','Video Intensity Plot',...
                  'numbertitle','off',...
                  'resize','off');
              
    % store frame index in app data.
    frameIndex = 1;
    setappdata(0, 'frameIndex', frameIndex);
    
    % plot mean intensity
    subplot(1, 3, 1);
    plot(mean_int, 'k+-'); 
    hold on;
    han_p1 = plot(frameIndex, mean_int(frameIndex), 'ro');
    
    xlabel('frame')
    ylabel('intensity');
    set(gca, 'FontSize', 18);
    
    % add some text about frame # and mean intensity in that frame
    txt1 = text(length(mean_int) - 120, min(mean_int) + 5, ...
        ['Frame: ' num2str(frameIndex)], 'FontSize', 18);
    txt2 = text(length(mean_int) - 120, min(mean_int) + 1, ...
        ['Mean: ' num2str(round(mean_int(frameIndex), 2))], 'FontSize', 18);
    
    % make the axis square
    axis square;
    
    % subplot 2/3 = frame image
    subplot(1, 3, [2 3]);
    han_p2 = imshow(vidFrames(frameIndex).cdata, [0 255]);

    % add keypressfcn response. arrows will increment or decrement frame.
    set(S.fh,'KeyPressFcn',{@(hObject, E) makeplot(hObject, E, mean_int, ...
        vidFrames, han_p1, han_p2, txt1, txt2)});
              
end


function makeplot(~,E, mean_int, vidFrames, hplot1, hplot2, txt1, txt2)
    % get current frameIndex
    frameIndex = getappdata(0, 'frameIndex');
    
    switch E.Key
        % increment or decrement frameIndex based on user input
        case 'rightarrow'
            frameIndex = frameIndex + 1;
            
        case 'leftarrow'
            frameIndex = frameIndex - 1;
        otherwise  
    end
    % save new frameIndex
    setappdata(0, 'frameIndex', frameIndex);
    
    % update plot data
    set(hplot1, 'ydata', mean_int(frameIndex));
    set(hplot1, 'xdata', frameIndex);
    set(hplot2, 'cdata', vidFrames(frameIndex).cdata);
    set(txt1, 'String', ['Frame: ' num2str(frameIndex)]);
    set(txt2, 'String', ['Mean: ' num2str(round(mean_int(frameIndex), 2))]);

    % re-draw plots
    drawnow;

end
