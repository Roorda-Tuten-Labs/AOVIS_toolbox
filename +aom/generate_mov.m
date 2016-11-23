function Mov = generate_mov(CFG)

    startframe = 3;
    fps = 30;
    
    % CFG.presentdur in msec
    presentdur = CFG.presentdur / 1000; 
    % how long is the presentation (in frames)
    stimdur = round(fps * presentdur); 

    % the index of your bitmap
    framenum0 = 2; % blank square
    framenum1 = 4; % stimulus
    framenum2 = 3; % cross
    

     % ---------- AOM0 IR parameters ---------- %
   
    % This vector tells the aom which image to play during each frame
    aom0seq = [zeros(1, startframe - 1), ones(1, stimdur) .* framenum0, ...
        zeros(1, 30 - startframe + 1 - stimdur)];
    
    % Set location relative to IR raster. (0,0) in middle of raster?
    aom0locx = zeros(size(aom0seq));
    aom0locy = zeros(size(aom0seq));
    
    % This sets the power for each frame
    aom0pow = ones(size(aom0seq));
    aom0pow(:) = 0;

    % ---------- AOM1 RED parameters ---------- %
    aom1seq = [zeros(1,startframe - 1), ones(1, stimdur) .* framenum2, ... 
        zeros(1, 30 - startframe + 1 - stimdur)];
    
    aom1pow = ones(size(aom1seq));
    aom1pow(:) = 0.0;
    aom1offx = zeros(size(aom1seq));
    aom1offy = zeros(size(aom1seq));
    
    % ---------- AOM2 GREEN parameters ---------- %
    % This vector tells the aom which image to play during each frame
    aom2seq = [zeros(1, startframe - 1), ones(1, stimdur) .* framenum1, ...
        zeros(1, 30 - startframe + 1 - stimdur)];
    
    % This sets the power for each frame
    aom2pow = ones(size(aom2seq));
    aom2pow(:) = 1; 
    aom2offx = zeros(size(aom2seq));
    aom2offy = zeros(size(aom2seq));
    
    % Ram was aiming to make a ramping stimulus??
    %
    % aom2pow = zeros(size(aom2seq));
    % Flat top increment
    % aom2pow (find(aom2seq)) = 1;

    % Flat top decrement
    % length_decrement = floor(stimdur / 2) ;
    % if rem(length_decrement,2) == 0 
    %     length_decrement = length_decrement - 1;
    % end
    % aom2pow (startframe : startframe + (stimdur-length_decrement)/2 - 1) = 1;
    % aom2pow(startframe + (stimdur-length_decrement)/2  : startframe + ...
    %   (stimdur-length_decrement)/2  + length_decrement -1) = 0;
    % aom2pow (endframe - (stimdur - length_decrement)/2 + 1:endframe) = 1;
    % aom2seq = aom2pow; 
    % aom2seq = aom2seq.*framenum; 

    % Increasing linear
    % slope = 1; 
    % temp = (slope/stimdur).*(0:round(stimdur/slope));
    % aom2pow(startframe:startframe + round(stimdur/slope)) = temp;
    % aom2seq = aom2pow; 
    % aom2seq(find(aom2seq)) = framenum;
    % trialIntensity = aom2pow;

    % ------------------------------------ %

    gainseq = CFG.gain * ones(size(aom2seq)); % tracking gain
    angleseq = zeros(size(aom2seq)); % not sure what angle does
    stimbeep = zeros(size(aom2seq)); % don't know if this is used
    stimbeep(startframe+stimdur-1) = 1;

    % ------ Set up movie parameters ------ %
    Mov.duration = CFG.videodur*fps;

    Mov.aom0seq = aom0seq;
    Mov.aom0pow = aom0pow;
    Mov.aom0locx = aom0locx;
    Mov.aom0locy = aom0locy;
    
    Mov.aom1seq = aom1seq;
    Mov.aom1pow = aom1pow;
    Mov.aom1offx = aom1offx;
    Mov.aom1offy = aom1offy;

    Mov.aom2seq = aom2seq;
    Mov.aom2pow = aom2pow;
    Mov.aom2offx = aom2offx;
    Mov.aom2offy = aom2offy;

    Mov.gainseq = gainseq;
    Mov.angleseq = angleseq;
    Mov.stimbeep = stimbeep;
    Mov.frm = 1;
    Mov.seq = '';

end