function add_delivery_error(subject, pix_per_degree, cross_size_pix, ...
    xcorr_thresh, overwrite)
    % add delivery error to existing color naming data files
    %
    % USAGE
    % add_delivery_error(subject, pix_per_degree, cross_size_pix,
    %                   xcorr_thresh, overwrite)
    %
    % INPUT
    % subject:          subject ID
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
    if nargin < 1
        subject = '20076R';
    end
    if nargin < 2
        pix_per_degree = 535;
    end
    if nargin < 3
        cross_size_pix = 17;
    end
    if nargin < 4
        xcorr_thresh = 0.6;
    end
    if nargin < 5
        overwrite = 0;
    end
    
    % base directory for videos
    base_dir = fullfile(filesep, 'Volumes', 'lyle', 'Video_Files', subject);
    
    % get the info about each directory
    datapaths = load_datapaths('dat', subject);
    ndirs = length(datapaths);
    
    % loop through every file in info
    for d = 1:ndirs
        for bkgd = {'white', 'blue'}
            % full path and name to color naming data
            dname = fullfile('dat', subject, 'raw', datapaths{d}.(bkgd{:}));
            viddir = fullfile(base_dir, datapaths{d}.([bkgd{:} '_video_dir']));

            % load color naming data
            exp_data = load(dname);
            exp_data = exp_data.exp_data;
                        
            % check if file already has delivery analysis
            if ~isfield(exp_data, 'delivery_error') || overwrite == 1
                % find the delivery error (this is slow)
                delivery_err = delivery.find_error(viddir, ...
                    cross_size_pix, xcorr_thresh, 'green', 1);

                % summarize the delivery error for each video (trial)
                summary = delivery.summarize_error(delivery_err, ...
                    pix_per_degree);

                % add delivery error and summary
                exp_data.delivery_error_raw = delivery_err;
                exp_data.delivery_error = summary;
                
                % save the raw data
                save(dname, 'exp_data');
                
            end
        end
    end
end

    
    
    