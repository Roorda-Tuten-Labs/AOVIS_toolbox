function log_transform_image()

    try
        if ismac
            [fnames, pathname, ~] = uigetfile('*', 'Select video file', ...
                '~/Data/Video_Folder/', 'multiselect', 'on'); 
        elseif ispc
            [fnames, pathname, ~] = uigetfile('*', 'Select video file', ...
                'D:\\Video_Folder\', 'multiselect', 'on');
        else
            [fnames, pathname, ~] = uigetfile('*', 'Select video file', ...
                'multiselect', 'on');
        end
    catch
        [fnames, pathname, ~] = uigetfile('*', 'Select video file', ...
            'multiselect', 'on');
    end
    
    
    for j = 1:length(fnames)
        fname = fnames{j};
        imagefilename = fullfile(pathname, fname);
        disp(imagefilename)
        c = imread(imagefilename);
        d = log10(double(c));
        d = d ./ max(max(d));

        figure;
        imshow(d);

        [~, name, ext] = fileparts(fname);

        newfilename = fullfile(pathname, [name 'log' ext]);
        imwrite(d, newfilename);
    end
end