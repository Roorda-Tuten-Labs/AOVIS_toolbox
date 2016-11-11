function [x1, y1] = find_cones_in_movie(movie_name)
% [x1, y1] = find_cones_in_movie(movie_name)
%
% Find cross in movies for cone mapping selection
%
% Author: W. Tuten October 2nd, 2012

%cross shape to search for
cross=zeros(11); cross(:,6)=1/11; %cross(6,:)=1;    

cdir = cd();
% create stimlocations text file
name = [cdir '\IR_target.txt'];     
fid = fopen(name,'wt');
AVIdetails=aviinfo(movie_name); %warning off last

startframe = 1;
endframe = AVIdetails.NumFrames-10; %change this range to add any subset of frames

% in 30 frame trial,last 10 usually have eyeblink
n = 1;
for framenum=startframe:endframe
    currentframe = double(frame2im(aviread(movie_name,framenum))); %warning off last
%     currentframe = currentframe(:,:,1);
    currentframe = currentframe/max(max(currentframe));

    currentframe = imfilter(currentframe,cross);
    % [row,col] = find(currentframe>0.9959);
    % currentframe(row,col)=0;
    % currentframebinary = im2bw(currentframe,0.9919); %changed from .9962
    currentframebinary = im2bw(currentframe,0.9960); %to find IR cross

    if(max(max(currentframebinary))==1)
        [~,j]=max(max(currentframebinary));
        [~,l]=max(currentframebinary(:,j));
        x(n,1) = j;
        y(n,1) = l;
        
        % write info to stimlocations.txt file for future reference
        fprintf(fid,'%g\t%g\t%g\n',j,l,framenum); 
        n = n+1;
    end
end
x1 = median(x);
y1 = median(y);
end

