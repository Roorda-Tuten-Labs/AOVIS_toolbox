
function movie_normalized(startPath, filterForStabVids)
% movie_normalized()
%
% USAGE This program will add movie frames together and generate an average
% image that has been normalized by the the number of frames that have
% contributed to each pixel in the image. The result is that there are no
% intensity drop offs at the edges of the averaged image that would
% normally be casued by fewere frames contributing to those regions. On the
% other hand, the edges of the frames are noisier since they comprose fewer
% averaged frames.
%
% You only need one copy of this program. You need to identify the folder
% that contains the avi files. It will add all avi files in the selected
% directory
%
% INPUT 
% 
% startPath:            directory containing video folders (optional). If
%                       not passed, uigetfile will launch from current
%                       working directory
% filterForStabVids:    flag when set to 1 means the code will search only
%                       for videos that end in "stabilized.avi" to speed up
%                       selection process; this file name is the default
%                       way ICANDI saves stabilized videos. set to 0 to
%                       display all "AVI" files
%
% NOTES Austin Roorda October 17, 2007 
% Edited BPS 14 Mar 2018 -- update to work with modern Matlab.
%
% 5-1-21                wst updated to accepting starting directory and to
%                       filter what gets displayed by uigetfile.

if nargin < 1
    startPath = '';
end
if nargin < 2
    filterForStabVids = 0;
end

if filterForStabVids == 1
    searchString = '*stabilized.avi';
else
    searchString = '*.avi';
end

[filenames, path] = uigetfile(searchString, 'Select video(s)', ...
    'MultiSelect', 'on', startPath);

nummovies = length(filenames);

for movienum = 1:nummovies
        
    vidName = fullfile(path, filenames{movienum});
    disp(['Summing frames from: ' vidName]);
    vidFrames = vid.read_video(vidName);    

    [height, width] = size(vidFrames(1).cdata);
    sumframe=zeros(height, width);
    sumframebinary=ones(height, width);

    %change this range to add any subset of frames
    startframe = 1; 
    endframe = length(vidFrames); 
    
    fprintf('Frames %g to %g are being co-added and saved to a tif file\n',...
        startframe,endframe);

    for framenum = startframe:endframe
        currentframe = double(vidFrames(framenum).cdata);
        
        %generate a binary image to locate the actual image pixels
        currentframebinary = imbinarize(currentframe, 1); 
        sumframe = sumframe + currentframe;

        % generate an image to divide by the sum image to generate an average
        sumframebinary = sumframebinary + currentframebinary; 

    end
    % normalize    
    sumframenew = sumframe ./ sumframebinary;
    
    % save file
    name = fullfile(path, ['sumnorm_' filenames{movienum} '.tif']);
    imwrite(sumframenew / max(max(sumframenew)), name, 'tif',...
        'Compression', 'none');
    
    % show image
    imshow(sumframenew / max(max(sumframenew)));    
    
end