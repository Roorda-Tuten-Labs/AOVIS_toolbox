function handles = setup_aom_gui()
% get a handle to the gui so that we can change its appearance later and
% set some basic parameters.
%
% OUTPUT
% handle to aom gui

    if exist('handles','var') == 0;
        handles = guihandles;
    end
    
    set(handles.aom1_state, 'String', 'Configuring Experiment...');

    % change appearance of AOM control window   
    set(handles.image_radio1, 'Enable', 'off');
    set(handles.seq_radio1, 'Enable', 'off');
    set(handles.im_popup1, 'Enable', 'off');
    set(handles.display_button, 'String', 'Running Exp...');
    set(handles.display_button, 'Enable', 'off');
    set(handles.aom1_state, 'String', 'On - Experiment Mode - Running Experiment');

end
