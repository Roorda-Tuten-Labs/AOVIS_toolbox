function install()
% Install AOVIS_toolbox onto your MATLAB path.

% Get current working directory
current_dir = pwd;
% Add it to the pathdef.m file used during boot.
addpath(current_dir);

% Add pieces of the UW toolbox from Boynton and Fine.
addpath(fullfile(current_dir, 'UW_toolbox-master', 'optimization'));
addpath(fullfile(current_dir, 'UW_toolbox-master', 'psychometricfunctions'));

status = savepath();

if status 
    fprintf(['Path was not saved. Most likely this was because you do not '...
        'have write access to pathdef.m. \nTry opening MATLAB as an '...
        'admin and running install() again.']);
else    
    disp('path saved to:')
    which pathdef.m -all;
end