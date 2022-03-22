function image_adder(varargin)
% image_adder(varargin)
%
% This function updates the original "movie_normalized" routine to
% incorporate some additional versatility. The user may now select either
% .avi or .tif files and the code will add them together using the approach
% as described by Austin below. I'm also taking a stab at using
% "inputParser" instead of the traditional "nargin" type approach.
%
% Austin's original description: This program will add movie frames
% together and generate an average image that has been normalized by the
% the number of frames that have contributed to each pixel in the image.
% The result is that there are no intensity drop offs at the edges of the
% averaged image that would normally be casued by fewere frames
% contributing to those regions. On the other hand, the edges of the frames
% are noisier since they comprise fewer averaged frames.
%
% REQUIRED KEY-VALUE PAIR INPUTS: 
%
% none
%
% OPTIONAL KEY-VALUE PAIR INPUTS:
%
% 'startPath'               STRING indicating the directory that contains
%                           the videos or images you want to add together.
%                           If this is not passed, uigetfile will launch
%                           from current working directory.
% 'imageType'               choose from 'avi' (DEFAULT) or 'tif'; this flag
%                           will tell the code what sort of input to look
%                           for when uigetfile is called
% 'filterForStabilized'     'true' or 'false'; DEFAULT = 'true'; flag when
%                           set to 'true' means the code will search only
%                           for videos that end in "stabilized.avi" to
%                           speed up selection process; this file name is
%                           the default way ICANDI saves stabilized videos.
%                           set to 'false' to display all "AVI" files
%
% Revision history/notes: 
% 10-17-07              austin roorda wrote the original
%                       version of this code as "movie_normalized"
% 3-14-18               brian schmidt updated to work with modern Matlab
%                       and incorporated into the AOVIS_toolbox
% 5-1-21                wst updated to accepting starting directory and to
%                       filter what gets displayed by uigetfile.
% 6-21-21               wst added ability to accept both .avi and .tif
%                       files; also switched to inputParser scheme which
%                       uses key-value pairs for inputs
%
% Example usage:
%
% To run in default mode, which launches uigetfile from the current working
% directory and only displays stabilized videos for selection:
%
% vid.image_adder;
%
% To point the code to a particular folder and search for '.tif' images to
% add together, try this:
%
% vid.image_adder('startPath', 'C:\Users\tuten\Desktop', 'imageType','tif')
%
% To process videos whose file names may not end in the ICANDI default
% 'stabilized.avi', try:
% 
% vid.image_adder('filterForStabilized', 'false');

% Sort out the inputs
% Establish defaults; will be overwritten if key/value pairs are passed
defaultStartPath = pwd;
defaultImageType = 'avi';
expectedImageTypes = {'avi', 'tif'}; % only accept these image types
defaultFilterForStabilized = 'true';
expectedFilterStrings = {'true', 'false'};

% Call inputParser and add passed parameters to "p"
p = inputParser;
addParameter(p, 'startPath', defaultStartPath, @ischar);
addParameter(p, 'imageType', defaultImageType, ...
    @(x) any(validatestring(x,expectedImageTypes)));
addParameter(p, 'filterForStabilized', defaultFilterForStabilized, ...
    @(x) any(validatestring(x,expectedFilterStrings)));
parse(p,varargin{:});

if strcmp(p.Results.imageType, 'tif')
    searchString = '*.tif';
else
    if strcmp(p.Results.filterForStabilized, 'true')
        searchString = '*stabilized.avi';
    else
        searchString = '*.avi';
    end
    
end

[filenames, path] = uigetfile(searchString, 'Select video(s)', ...
    'MultiSelect', 'on', p.Results.startPath);

if ~iscell(filenames) % if user only selected one file name, uigetfile returns a string rather than a cell array
    % force it into cell format, otherwise the number of files computed
    % with "numel" below will correspond to the length of the string rather
    % than the number of elements in the cell (i.e. the number of files)
    filenames = {filenames};
end
numfiles = numel(filenames);

if strcmp(p.Results.imageType, 'avi') % Process individual trial videos
    h = waitbar(0, sprintf('Processing video %d of %d...', 0, numfiles)); 
    for filenum = 1:numfiles
        fileName = fullfile(path, filenames{filenum});
        disp(['Summing frames from: ' fileName]);
        imFrames = vid.read_video(fileName);
        [height, width] = size(imFrames(1).cdata);
        sumframe=zeros(height, width);
        sumframebinary=ones(height, width);
        
        % Can change this range to add any subset of frames; for now just
        % use all of them
        startframe = 1;
        endframe = length(imFrames);
        
        fprintf('Frames %g to %g are being co-added and saved to a tif file\n',...
            startframe,endframe);
        
        for framenum = startframe:endframe
            currentframe = double(imFrames(framenum).cdata);
            
            %generate a binary image to locate the actual image pixels
            currentframebinary = imbinarize(currentframe, 1);
            sumframe = sumframe + currentframe;
            
            % generate an image to divide by the sum image to generate an average
            sumframebinary = sumframebinary + currentframebinary;
            
        end
        % normalize
        sumframenew = sumframe ./ sumframebinary;
        
        % save file
        [rootFolder, fileRoot, ~] = fileparts(fileName);
        saveName = fullfile(rootFolder, ['sumnorm_' fileRoot '.tif']);
        imwrite(sumframenew ./ max(sumframenew(:)), saveName, 'tif',...
            'Compression', 'none');
        
        % show image
        imshow(sumframenew / max(max(sumframenew)));
        title({fileRoot});
        waitbar(filenum/numfiles, h, sprintf('Processing video %d of %d...', filenum, numfiles));        
    end
    close(h);
    
elseif strcmp(p.Results.imageType, 'tif') % Process batch of .tif images
    fprintf('Summing %d images from: %s\n', numfiles, path);
    if numfiles == 1 % user only selected one image
        error('Need to select more than one image to derive any benefit from this code!');
    else
        for filenum = 1:numfiles
            fileName = fullfile(path, filenames{filenum}); % get the file name
            if filenum == 1 % on the first time through, pre-allocate "sumframe" and "sumframebinary" matrices
                currentframe = double(imread(fileName)); % read in current frame
                %generate a binary image to locate the actual image pixels
                currentframebinary = imbinarize(currentframe, 1);
                sumframe = zeros(size(currentframe)); % pre-allocate
                sumframebinary = sumframe+1; % pre-allocate
            else
                currentframe = double(imread(fileName)); % read in current frame
                %generate a binary image to locate the actual image pixels
                currentframebinary = imbinarize(currentframe, 1);
            end
            % do the adding
            sumframe = sumframe + currentframe; % add to sumframe
            sumframebinary = sumframebinary + currentframebinary; % add to binarized image
        end
        % normalize
        sumframenew = sumframe ./ sumframebinary;
        
        % save file
        [~, fileRoot, ~] = fileparts(path(1:end-1));
        saveName = fullfile(path, ['sumframe_' fileRoot '.tif']);
        imwrite(sumframenew ./ max(sumframenew(:)), saveName, 'tif',...
            'Compression', 'none');
        
        % show image
        imshow(sumframenew / max(max(sumframenew)));
        title({fileRoot});
    end
end