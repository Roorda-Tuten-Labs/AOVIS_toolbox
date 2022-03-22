function add_delivery_error(subject, datapaths, datadir, pix_per_degree, ...
    cross_size_pix, xcorr_thresh, overwrite_raw, overwrite_summary)
    % add delivery error to existing color naming data files
    %
    % USAGE
    % add_delivery_error(subject, datapaths pix_per_degree, cross_size_pix,
    %                   xcorr_thresh, overwrite)
    %
    % INPUT
    % subject:          subject ID
    % datapaths:        a struct of paths to video files and the data file.
    %                   The struct should be in the form:
    %                       d{i}.data_file = mat file to save delivery info
    %                       d{i}.video_dir = directory with videos
    %                   The program will iterate over the length of d.
    % datadir:          directory where data_files are stored. The program
    %                   will append datadir with each d{i}.data_file.
    % pix_per_degree:   for converting to arcmin.
    % cross_size_pix:   size of the cross used in cross correlation, 
    %                   specified in pixels. Default = 17.
    % xcorr_thresh:     threshold for detecting a cross. default = 0.6.
    % overwrite_raw:    boolean. choose to overwrite files that already
    %                   have delivery error analysis. Only set this flag to
    %                   true if you are certain you know what you are
    %                   doing.
    % overwrite_summary:boolean. Choose to overwrite summary statistics.
    %                   Summary stats are added as a separate field and
    %                   include the mean and standard deviation of each 
    %                   trial (see below).
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

    if nargin < 4
        pix_per_degree = 555;
    end
    if nargin < 5
        cross_size_pix = 17;
    end
    if nargin < 6
        xcorr_thresh = 0.6;
    end
    if nargin < 7
        overwrite_raw = 0;
    end
    if nargin < 8
        overwrite_summary = 0;
    end

    % base directory for videos
    if ismac
        base_dir = fullfile(filesep, 'Volumes', 'lyle', 'Video_Files', ...
            subject);
    elseif ~ismac && isunix
        base_dir = fullfile(filesep, 'media', 'brian', 'lyle', ...
            'Video_Files', subject);
    end
        
    % get the info about each directory  
    ndirs = length(datapaths);
    
    % check if parfor loop should be run
    run_parfor_loop = 0;
    if overwrite_raw
        run_parfor_loop = 1;
    else
        for d = 1:ndirs
            % full path and name to color naming data: in hue_scaling
            % project directory
            dname = fullfile(datadir, [datapaths{d}.data_file '.mat']);

            % load color naming data
            exp_data = load(dname);
            exp_data = exp_data.exp_data;

            % check if file already has delivery analysis
            if ~isfield(exp_data, 'delivery_error_raw') || ...
                    overwrite_raw == 1                
                run_parfor_loop = run_parfor_loop + 1;
            end
        end 
    end
    
    % only run the for loop if there is new data to be analyzed.
    if run_parfor_loop > 0
        % loop through every file in info
        for d = 1:ndirs
            % full path and name to color naming data: in hue_scaling
            % project directory
            dname = fullfile(datadir, [datapaths{d}.data_file '.mat']);

            % full path to videos on external hard drive, lyle.
            viddir = fullfile(base_dir, datapaths{d}.video_dir);

            % load color naming data
            exp_data = load(dname);
            exp_data = exp_data.exp_data;

            savedata = 0;
            % check if file already has delivery analysis
            if ~isfield(exp_data, 'delivery_error_raw') || ...
                    overwrite_raw == 1
                if isfield(exp_data, 'delivery_error_raw')
                    if exp_data.delivery_error_raw
                        exp_data = rmfield(exp_data, 'delivery_error_raw');
                    end
                end
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

            if ~isfield(exp_data, 'delivery_error') || ...
                    overwrite_summary == 1
                % offsets that were selected in AOMcontrol
                %offsets_xy = exp_data.offsets;
                % summarize the delivery error for each video (trial)
                summary = delivery.summarize_error(delivery_err, ...
                    pix_per_degree); %, offsets_xy);
                % add delivery error summary
                exp_data.delivery_error = summary;
                savedata = 1;
            end

            if savedata
                % if saving need to store the name and data file in a
                % struct for saving later. parfor loop can not contain 
                % a call to save().
                dfiles(d).name = dname;
                dfiles(d).data = exp_data;

            end                

        end
        % shut down the parallel pool
        poolobj = gcp('nocreate');
        delete(poolobj);
    else
            % loop through every file in info
        for d = 1:ndirs
            % full path and name to color naming data: in hue_scaling
            % project directory
            dname = fullfile(datadir, [datapaths{d}.data_file '.mat']);

            % load color naming data
            exp_data = load(dname);
            exp_data = exp_data.exp_data;

            savedata = 0;

            % read in delivery error from data.
            delivery_err = exp_data.delivery_error_raw;

            if ~isfield(exp_data, 'delivery_error') || ...
                    overwrite_summary == 1
                % offsets that were selected in AOMcontrol
                %offsets_xy = exp_data.offsets;
                % summarize the delivery error for each video (trial)
                summary = delivery.summarize_error(delivery_err, ...
                    pix_per_degree); %, offsets_xy);
                % add delivery error summary
                exp_data.delivery_error = summary;
                savedata = 1;
            end

            if savedata
                % if saving need to store the name and data file in a
                % struct for saving later. parfor loop can not contain 
                % a call to save().
                dfiles(d).name = dname;
                dfiles(d).data = exp_data;

            end                

        end

    end

    if exist('dfiles', 'var')
        % save the raw data outside of the parfor loop.
        for d = 1:length(dfiles)
            if ~isempty(dfiles(d))
                dname = dfiles(d).name;
                exp_data = dfiles(d).data; %#ok
                save(dname, 'exp_data');
            end
        end
    end
    
end


    
    
    