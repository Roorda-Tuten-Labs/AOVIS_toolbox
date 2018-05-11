function [x_interest, y_interest, img_map] =  find_cones(cone_size, img,...
    method, xcorr_threshold, show_plot)
% Original function written by R. Sabesan
% Sent to BPS on 1 Sept 2016.
%
% INPUT
% cone_size         in pixels. should be an odd number. will be force into 
%                   odd if an even number is passed.
% img               img matrix. 
% method            cone selection method. auto or manual.
% xcorr_threshold   default = 0.6.
% show_plot         decide whether to show the plot or not.

import util.*

if nargin < 5
    show_plot = 1;
end
if nargin < 4
    xcorr_threshold = 0.6;
end
if nargin < 3
    method = 'auto';
end
if nargin < 2 || isempty(img)
    [fname, pathname, ~] = uigetfile('*', 'Select image file'); 
    imgfile = fullfile(pathname, fname);
    img = imread(imgfile);
end
if nargin < 1
    cone_size = 7;
end

if strcmpi(method, 'auto')
    % cone_size = 7; %odd number please

    [conex coney] = meshgrid(-floor(cone_size / 2):floor(cone_size / 2));

    cone = double(exp(-(conex.^2 + coney.^2) / (cone_size / 2).^2 ));

    xcorr = array.normxcorr2f(cone, img);

    [x,y] = find(xcorr > xcorr_threshold);

    max_num = xcorr(sub2ind(size(xcorr),x,y)); 
    xcorr_thresh = xcorr > xcorr_threshold;

    % figure; imagesc(xcorr > 0.5);colormap(gray); axis square, axis tight;

    all_maxs = [x,y,max_num];

    all_maxs_sorted = sortrows(all_maxs,-3);

    jj = 1;
    while 1
        ii = 1;

        x_interest(jj,1) = all_maxs_sorted(ii,2) ;
        y_interest(jj,1) = all_maxs_sorted(ii,1) ;

        to_compare = imcrop(xcorr,[all_maxs_sorted(ii,2) - ...
            (size(cone,2)/2) , all_maxs_sorted(ii,1) - ...
            (size(cone,1)/2) , (size(cone,2)) (size(cone,1))]);

        [duplicates, row_indices] = setdiff(all_maxs_sorted(:,3),...
            to_compare(:));
        
        all_maxs_sorted_new = sortrows(all_maxs_sorted(row_indices,:),...
            -3);
        
        all_maxs_sorted = all_maxs_sorted_new;
        jj = jj + 1;

        size(all_maxs_sorted,1);
        if isempty(all_maxs_sorted)
            break
        end

    end

    if show_plot
        h = figure(259); 
        imshow(img,'InitialMagnification', 500, 'Border', 'Tight');
        colormap(gray); 
        caxis([min(img(:)), max(img(:))]); hold on;

        axis equal, axis off;
        for ii = 1:size(x_interest,1)
            plot(x_interest(ii,1), y_interest(ii,1),'r.');  
            %text(x_interest(ii,1)+1,y_interest(ii,1),[num2str(ii)],...
            %'Color','b','FontWeight','bold');
        end

        hold off;
        img_map = frame2im(getframe(h));
    else
        img_map = 'run with show_plot==1 to get img_map';
    end
    % close 259;
else
    
    Redo = 1;

    while Redo

        h = figure (259);

        imshow(img,'InitialMagnification', 500, 'Border', 'Tight')
        colormap(gray); 
        caxis([min(img(:)),max(img(:))]);
        hold on, 
        axis equal, axis off;

            n = 1; clear X Y;
        while 1

            [x, y, clicks] = ginput(1);

            X(n,1)= x; Y(n,1)= y;
            plot(x,y,'.b');hold on
            %text(X(n,1)+1,Y(n,1),[num2str(n)],'Color','b',...
            %'FontWeight','bold')   

            n = n+1;

            if clicks == 3
                break
            end

        end
        
        hold off;

        choice = questdlg('Accept cone selections ?', ...
        'Manual cone selection', ...
        'Yes','Redo','Yes');

        switch choice
          case 'Redo'
              Redo = 1;

              close 259
          case 'Yes'
              Redo = 0;
              img_map = frame2im(getframe(h));

                % [offsets_manual] = [X,Y];
              close 259;
        end

        x_interest = X;
        y_interest = Y;
    end
end


    