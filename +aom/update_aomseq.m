function aomseq = update_aomseq(presentdur, framenum, startframe)
    % Change the frame number called during aomseq
    %
    % USAGE
    % aomseq = update_aomseq(CFG, framenum)
    % 
    % INPUT
    % presentdur:   duration of stimulus in msec
    % framenum:     frame number of bmp, buf, etc to use during stimulus
    % startframe:   default = 3.
    %
    % OUTPUT
    % aomseq:       aom sequence with updated frame
    %
    if nargin < 3 || isempty(startframe)
        startframe = 3;
    end
    
    fps = 30;
    
    % presentdur in msec, convert to s
    presentdur = presentdur / 1000; 
    
    % how long is the presentation (in frames)
    stimdur = round(fps * presentdur); 
    
    % This vector tells the aom which image to play during each frame
    aomseq = [zeros(1, startframe - 1), ones(1, stimdur) .* framenum, ...
        zeros(1, 30 - startframe + 1 - stimdur)];
end