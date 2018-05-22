function [img] = sumframe_from_stabilized_movie(path, filename, ...
    frames_to_exclude, X_cross_loc, Y_cross_loc)

    %AVIdetails=aviinfo([path,filename]); warning off all
    readerobj = VideoReader(fullfile(path, filename));
    vidFrames = read(readerobj);
    %startframe = 1; 
    %endframe = readerobj.NumberOfFrames; 

    sumframe=zeros(readerobj.Height,readerobj.Width);
    sumframebinary=ones(readerobj.Height,readerobj.Width);
    frames_of_interest = setdiff(1:readerobj.NumberOfFrames,...
        frames_to_exclude);
    
    for ii = 1:length(frames_of_interest)
        currentframe = double(vidFrames(:, :, frames_of_interest(ii)));
        currentframebinary = im2bw(currentframe,0.01); 

        if  sum(max(currentframebinary))<10000 || sum(max(currentframebinary'))<10000
            sumframe=sumframe+currentframe(:,:,1);
            sumframebinary = sumframebinary+currentframebinary; 
        else
%             %fprintf('Dropped frame# %g from movie %s\n', framenum, fname{movienum});
%             fprintf('Dropped frame# %g from movie %s\n', framenum, a(movienum).name);
        end
    end
    name = fullfile(path, ['sumnorm_' filename(1:end-4) '_' ...
        strrep(strrep(strrep(datestr(now),'-',''),' ','x'),':','') '_',...
        num2str(floor(X_cross_loc)),'_',...
        num2str(floor(Y_cross_loc)) '.tif']);
    
    sumframenew = sumframe./sumframebinary;
    
    
    
    img = sumframenew/max(max(sumframenew));
    
    imwrite(sumframenew/max(max(sumframenew)),name,'tif','Compression','none');