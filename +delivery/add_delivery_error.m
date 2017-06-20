function add_delivery_error(subject, datapaths, pix_per_degree, ...
    cross_size_pix, xcorr_thresh, overwrite)
    % add delivery error to existing color naming data files
    %
    % USAGE
    % add_delivery_error(subject, datapaths pix_per_degree, cross_size_pix,
    %                   xcorr_thresh, overwrite)
    %
    % INPUT
    % subject:          subject ID
    % datapaths:        
    % pix_per_degree:   for converting to arcmin.
    % cross_size_pix:   size of the cross used in cross correlation, 
    %                   specified in pixels. Default = 17.
    % xcorr_thresh:     threshold for detecting a cross. default = 0.6.
    % overwrite:        boolean. choose to overwrite files that already
    %                   have delivery error analysis. Only set this flag to
    %                   true if you are certain you know what you are
    %                   doing.
    %
    % OUTPUT
    % Each mat data file containing hue scaling data associated with the
    % videos being analyzed is appended with the results of this analysis.
    %
    % The fields added to the mat files are:
    % delivery_error_raw:   contains the pixel location of the green
    %                       cross for each frame.
    % delivery_error:       comes from summarize_error.m and is the mean for 
    %                       each video (trial).
    %

    if nargin < 3
        pix_per_degree = 555;
    end
    if nargin < 4
        cross_size_pix = 17;
    end
    if nargin < 5
        xcorr_thresh = 0.6;
    end
    if nargin < 6
        overwrite = 0;
    end
    
    subject = strsplit(subject, '/');
    subject_name = subject{1};
    if length(subject) > 1
        subject_subname = subject{2};
    else
        subject_subname = '';
    end
    % base directory for videos    
    base_dir = fullfile(filesep, 'Volumes', 'lyle', 'Video_Files', ...
        subject_name);
    
    % get the info about each directory  
    ndirs = length(datapaths);
    
    % figure out which background conditions are present in datapaths
    % struct
    bkgds = {'white', 'blue'};
    for bkgd = 1:length(bkgds)
        if ~isfield(datapaths{1}, (bkgds{bkgd}))
            % if it is not in the list of datapaths, delete.
            bkgds(bkgd) = [];
        end
    end
    
    % loop through every file in info
    for d = 1:ndirs
        for bkgd = bkgds
            % full path and name to color naming data: in hue_scaling
            % project directory
            dname = fullfile('dat', subject_name, subject_subname, ...
                'raw', datapaths{d}.(bkgd{:}).data_file);
            
            % full path to videos on external hard drive, lyle.
            viddir = fullfile(base_dir, datapaths{d}.(bkgd{:}).video_dir);

            % load color naming data
            exp_data = load(dname);
            exp_data = exp_data.exp_data;
                        
            savedata = 0;
            % check if file already has delivery analysis
            if ~isfield(exp_data, 'delivery_error_raw')% || overwrite == 1
                
                % find the delivery error (this is slow)
                delivery_err = delivery.find_error(viddir, ...
                    cross_size_pix, xcorr_thresh, 'green', 1);
                % add delivery error
                exp_data.delivery_error_raw = delivery_err;   
                savedata = 1;
            else
                % read in delivery error from data.
                delivery_err = exp_data.delivery_error_raw;
            end

            if ~isfield(exp_data, 'delivery_error') || overwrite == 1
                % summarize the delivery error for each video (trial)
                summary = delivery.summarize_error(delivery_err, ...
                    pix_per_degree);
                % add delivery error summary
                exp_data.delivery_error = summary;
                savedata = 1;
            end
                
            if savedata
                % save the raw data
                save(dname, 'exp_data');
            end
                
        end
    end
end


    
    
    