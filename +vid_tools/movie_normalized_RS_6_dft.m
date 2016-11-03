%This program will add movie frames together and generate an average image that has been normalized by the the number of frames 
%that have contributed to each pixel in the image. The result is that there
%are no intensity drop offs at the edges of the averaged image that would normally be casued by fewere frames contributing to those regions. 
%On the other hand, the edges of the frames are noisier since they comprose fewer averaged frames.

% You only need one copy of this program. You need to identify
% the folder that contains the avi files. It will add all avi files in the
% selected directory
%Austin Roorda October 17, 2007

clear all
close all
%%
% [fname, pname] = uigetfile('*.AVI;*.avi', 'Select stabilized AVI files for adding', 'MultiSelect', 'on');
[fnames pname] = uigetfile('*.AVI;*.avi', 'Select stabilized AVI files for adding', 'MultiSelect', 'on');
    do_cross_correl           = 1;
    reference_frame_num       = 50
    norm_cross_correl_thresh  = 0.6;
    
    
movienum = 1;
% pname = uigetdir;
a= dir([pname '\*.avi']);

fnames=cellstr(fnames);
nummovies = size(fnames,2);

for movienum = 1:nummovies
    figure
    %fname = a(movienum).name

    AVIdetails=aviinfo([pname fnames{movienum}]);

    
    startframe = 10;%121; 
    endframe = 150; %AVIdetails.NumFrames ; %change this range to add any subset of frames
    
    reference_frame = (frame2im(aviread([pname fnames{movienum}],reference_frame_num)));
    if do_cross_correl              
        [maxx maxy] =  ind2sub(size(reference_frame),max(find(reference_frame~=0)));
        [minx miny] =  ind2sub(size(reference_frame),min(find(reference_frame~=0)));
        roi_ref_pxls   = 512;
        rect_ref = [ 80, 80, roi_ref_pxls, roi_ref_pxls];
        rect_current = [ 80, 80, roi_ref_pxls, roi_ref_pxls];
        reference_frame_cropped = imcrop(reference_frame, rect_ref);
        reference_frame_cropped = double(reference_frame_cropped);
    end
    
    image_matrix = zeros(AVIdetails.Height,AVIdetails.Width,endframe);
    cross_correl_matrix = zeros(1,endframe);
    
    
    row_max_loc = zeros(1,endframe);
    col_max_loc = zeros(1,endframe);
    
    tic
    for framenum = startframe:endframe
        image_matrix (:,:,framenum) = double(frame2im(aviread([pname fnames{movienum}],framenum)));
       [msgstr msgid] = lastwarn;
%         warning('off', msgid);
        
        if do_cross_correl
        currentframe_cropped = double(imcrop(image_matrix (:,:,framenum), rect_current));
     
%         cross_correl = Norm_xcorr2_in_mex(reference_frame_cropped, currentframe_cropped);
        
        [output not_used ] = dftregistration(fft2(reference_frame_cropped),fft2(currentframe_cropped),5);
  
    row_max_loc(:,framenum) = output(4); col_max_loc(:,framenum) = output(3);
    cross_correl_matrix(:,framenum) = output(1);
%         cross_correl = reshape(cross_correl,[length(cross_correl).^0.5 length(cross_correl).^0.5]);
        
%         [cross_correl_matrix(:,framenum), row_max_loc(:,framenum), col_max_loc(:,framenum) ] = max2D_RS(cross_correl); 
        
        
        end
        
    end
    
    keep_going = 1;
    while(keep_going == 1)
     
        
    if do_cross_correl
    frames_of_interest = find(cross_correl_matrix(1,:) > norm_cross_correl_thresh)
    Nans =   find(isnan(cross_correl_matrix(1,:))) ; 
    frames_of_interest = setdiff(frames_of_interest,Nans);
    
    row_nogood = find(row_max_loc > 60); 
    col_nogood = find(col_max_loc > 60); 
    frames_of_interest = setdiff(frames_of_interest,row_nogood);
    frames_of_interest = setdiff(frames_of_interest,col_nogood);
    not_of_interest    = setxor (startframe:endframe, frames_of_interest);
    
    
    else
    frames_of_interest = startframe:endframe;
    not_of_interest    = [];
    end
    
    fprintf('Frames %g to %g are being co-added and saved to a tif file\n',startframe,endframe);
    
    
    good_frames = ones(0);
    bad_frames  = ones(0);
    sumframe=zeros(AVIdetails.Height,AVIdetails.Width);
    sumframebinary=ones(AVIdetails.Height,AVIdetails.Width);

    
  
       for ii = 1: length(frames_of_interest)
       
                currentframe = image_matrix(:,:,frames_of_interest(ii));
                currentframe = shift(currentframe,(col_max_loc(frames_of_interest(ii))),(row_max_loc(frames_of_interest(ii))));
             %generate a binary image to locate the actual image pixels
                currentframebinary = im2bw(currentframe,0.01); 
            %if the image is not too distorted then add to sum
                if  ( (sum(max(currentframebinary))<515|sum(max(currentframebinary'))<515)) 
                sumframe=sumframe+currentframe(:,:,1);
                sumframebinary = sumframebinary+(currentframebinary); % generate an image to divide by the sum image to generate an average
                good_frames = [good_frames frames_of_interest(ii)];
                figure(1);imagesc(currentframe);colormap(gray);axis square, axis tight; 
                else
                fprintf('Dropped frame# %g from movie %s\n', frames_of_interest(ii), fnames{movienum});
                bad_frames = [bad_frames frames_of_interest(ii)];
                end
                
                
         end
            
        
         bad_frames = union (bad_frames, not_of_interest);
    

        
      
    toc
    disp(['Good frames = ',num2str(length(good_frames))])
    disp(['Bad frames = ',num2str(length(bad_frames))])
    
    name = [pname 'sumnorm_' fnames{movienum}(1:end-4) '_do_xcorrel_' ...
        num2str(do_cross_correl) '_reference_frm_#_' num2str(reference_frame_num)...
        '_xcorrel_thresh_' num2str(norm_cross_correl_thresh) '_'... 
           strrep(strrep(strrep(datestr(now),'-',''),' ','x'),':','')  '.tif'];
    %name = [pname '\sumnorm_' fname '.tif']
    sumframenew = sumframe./sumframebinary;
    figure;
    imshow(sumframenew/max(max(sumframenew)));drawnow;
    
    R = input(['Replace old threshold = ',num2str(norm_cross_correl_thresh), '  by new threshold (y/n) ?'], 's');
    if upper(R) == 'Y'
        norm_cross_correl_thresh = input('Enter new threshold : ');
        keep_going =1 ;
    
    else
       keep_going=0;
    end
    
    
    end
    
    
    
%     imwrite(sumframenew/max(max(sumframenew)),name,'tif','Compression','n
%     one');
 end