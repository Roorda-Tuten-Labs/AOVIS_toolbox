function mosaic = load_locs(subject)
    if nargin < 1
        subject = '20076R';
    end

    if isnumeric(subject)
        subject = num2str(subject);
    end
    
    if strcmpi(subject(1:5), '20076')
        subj = '20076R';
        basedir = fullfile(fileparts(mfilename('fullpath')), 'dat', subj);
        dat = load(fullfile(basedir, 'LMS_cones.mat'));
        fnames = fieldnames(dat); %LMS_cones_10001R;
        mosaic = dat.(fnames{1}); 
        cone_type = mosaic(:, 3);
        if iscell(mosaic)
            tmp = cone_type;
            cone_type = zeros(length(cone_type), 1);
            cone_type(strcmpi(tmp, 'l')) = 3;
            cone_type(strcmpi(tmp, 'm')) = 2;
            cone_type(strcmpi(tmp, 's')) = 1;
            mosaic = cell2mat(mosaic(:, 1:2));
            mosaic = [mosaic cone_type];
        end

        mosaic(:, 1:2) = rot90(mosaic(:, 1:2))';
        mosaic(:, 2) = max(mosaic(:, 2)) - mosaic(:, 2);
    elseif strcmpi(subject(1:5), '20053')
        subj = '20053R';
        basedir = fullfile(fileparts(mfilename('fullpath')), 'dat', subj);
        dat = load(fullfile(basedir, 'LMS_cones.mat'));
        fnames = fieldnames(dat); %LMS_cones_10001R;
        mosaic = dat.(fnames{1}); 
        cone_type = mosaic(:, 3);
        if iscell(mosaic)
            tmp = cone_type;
            cone_type = zeros(length(cone_type), 1);
            cone_type(strcmpi(tmp, 'l')) = 3;
            cone_type(strcmpi(tmp, 'm')) = 2;
            cone_type(strcmpi(tmp, 's')) = 1;
            mosaic = cell2mat(mosaic(:, 1:2));
            mosaic = [mosaic cone_type];
        end

        mosaic(:, 1:2) = rot90(mosaic(:, 1:2))';
        mosaic(:, 2) = max(mosaic(:, 2)) - mosaic(:, 2);
        
    elseif strcmpi(subject(1:5), '20092')
        subj = '20092L';
        basedir = fullfile(fileparts(mfilename('fullpath')), 'dat', subj);
        dat = load(fullfile(basedir, 'LMS_cones.mat'));
        mosaic = dat.LMS_cones;        
        
    else                
        error('Only mosaics currently available are 20076 and 20053')
    end