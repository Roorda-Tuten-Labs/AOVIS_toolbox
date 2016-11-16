function create_default_stim

    dummy=ones(10, 10);
    if isdir(fullfile(pwd, 'tempStimulus')) == 0;
        mkdir(fullfile(pwd, 'tempStimulus'));
        cd(fullfile(pwd, 'tempStimulus'));
        imwrite(dummy, 'frame2.bmp');
        
    else
        cd(fullfile(pwd, 'tempStimulus'));
        delete ('*.*');
        imwrite(dummy, 'frame2.bmp');
        
    end
    cd ..;
    
end
