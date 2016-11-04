function Mov = generate_mov(CFG)

    startframe = 3;
    fps = 30;
    presentdur = CFG.presentdur / 1000; % CFG.presentdur in msec
    stimdur = round(fps * presentdur); %how long is the presentation
    %numframes = fps*CFG.videodur;
    %endframe = startframe + stimdur - 1; 

    framenum = 2; %the index of your bitmap
    framenum2 = 3;
    %framenum3 = 4;

    aom1seq = [zeros(1,startframe-1), ...
               ones(1,stimdur).*framenum, zeros(1,30-startframe+1-stimdur)];
    aom1pow = ones(size(aom1seq)); % usual
    aom1pow(:) = 1; % usual

    % --------- Ram was aiming to make a ramping stimulus?? ---------- %
    % aom1pow = zeros(size(aom1seq));
    % Flat top increment
    % aom1pow (find(aom1seq)) = 1;

    % Flat top decrement
    % length_decrement = floor(stimdur/2) ;
    % if rem(length_decrement,2) == 0 
    %     length_decrement = length_decrement - 1;
    % end
    % aom1pow (startframe : startframe + (stimdur-length_decrement)/2 - 1) = 1;
    % aom1pow(startframe + (stimdur-length_decrement)/2  : startframe + ...
    %   (stimdur-length_decrement)/2  + length_decrement -1) = 0;
    % aom1pow (endframe - (stimdur - length_decrement)/2 + 1:endframe) = 1;
    % aom1seq = aom1pow; 
    % aom1seq = aom1seq.*framenum; 

    %Increasing linear
    % slope = 1; 
    % temp = (slope/stimdur).*(0:round(stimdur/slope));
    % aom1pow(startframe:startframe + round(stimdur/slope)) = temp;
    % aom1seq = aom1pow; 
    % aom1seq(find(aom1seq)) = framenum;
    % trialIntensity = aom1pow;
    % ----------------------------------------------------- %

    aom1offx = zeros(size(aom1seq));
    aom1offy = zeros(size(aom1seq));

    %%%%%%%%%%%% AOM0 (IR) parameters %%%%%%%%%%%%%%%%

    % aom0seq = ones(size(aom1seq));
    % aom0seq = zeros(size(aom1seq));
    % aom0seq = [zeros(1,cueframe-1) ones(1,stimdur).* ...
    %    framenum3 zeros(1,30-startframe+1-stimdur)];
    aom0seq = [zeros(1,startframe-1) ones(1,stimdur).* ...
        framenum2 zeros(1,30-startframe+1-stimdur)];
    aom2seq = [zeros(1,startframe-1) ones(1,stimdur).* ...
        framenum2 zeros(1,30-startframe+1-stimdur)];

    aom0locx = zeros(size(aom1seq));
    aom0locy = zeros(size(aom1seq));
    aom0pow = ones(size(aom1seq));
    aom0pow(:) = 0;

    aom2pow = ones(size(aom1seq));
    aom2pow(:) = 100; % 0.25 in ColorNaming_ConeSelection.m
    aom2locx = zeros(size(aom1seq));
    aom2locy = zeros(size(aom1seq));
    aom2offx = zeros(size(aom1seq));
    aom2offx(:) = 100;
    aom2offy = zeros(size(aom1seq));
    aom2offy(:) = 100;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    gainseq = CFG.gain * ones(size(aom1seq));
    angleseq = zeros(size(aom1seq));
    stimbeep = zeros(size(aom1seq));
    stimbeep(startframe+stimdur-1) = 1;
    %stimbeep = [zeros(1,startframe+stimdur-1) 1 zeros(1,30-startframe-stimdur+2)];

    % ------ Set up movie parameters ------ %
    Mov.duration = CFG.videodur*fps;

    Mov.aom0seq = aom0seq;
    % Mov.aom0seq = ones(size(aom0seq,2)); %comment when running online
    Mov.aom1seq = aom1seq;
    Mov.aom0pow = aom0pow;

    Mov.aom1pow = aom1pow;
    Mov.aom0locx = aom0locx;
    Mov.aom0locy = aom0locy;
    Mov.aom1offx = aom1offx;
    Mov.aom1offy = aom1offy;

    Mov.aom2seq = aom2seq;
    % Mov.aom2seq = zeros(size(aom2seq,2)); %comment when running online
    Mov.aom2pow = aom2pow;
    Mov.aom2locx = aom2locx;
    Mov.aom2locy = aom2locy;
    Mov.aom2offx = aom2offx;
    Mov.aom2offy = aom2offy;

    Mov.gainseq = gainseq;
    Mov.angleseq = angleseq;
    Mov.stimbeep = stimbeep;
    Mov.frm = 1;
    Mov.seq = '';

end