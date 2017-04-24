function [img_map, offset_cropped] = auto_cone_select(img_crop, rect_position)
    % [img_map, offset_cropped] = auto_cone_select(img_crop, rect_position)
    %
    % This function was written by R. Sabesan. It has not been tested and
    % is unclear if it ever worked. Use at your own risk.
    %
    xcorr_threshold = 0.6;
    cone_size = 5; %odd number please

    [conex, coney] = meshgrid(-floor(cone_size/2) : floor(cone_size/2));
    cone = double( exp(-(conex.^2 + coney.^2) / (cone_size/2).^2 ));
    xcorr = normxcorr2f(cone, img_crop);
    [x,y] = find(xcorr > xcorr_threshold);
    
    max_num = xcorr(sub2ind(size(xcorr),x,y));
    %xcorr_thresh = xcorr > xcorr_threshold;
    % figure; imagesc(xcorr > 0.5);colormap(gray); axis square, axis tight;

    all_maxs = [x,y,max_num];
    all_maxs_sorted = sortrows(all_maxs,-3);

    jj = 1;
    while 1
        ii = 1;
        x_interest(jj,1) = all_maxs_sorted(ii,2) ;
        y_interest(jj,1) = all_maxs_sorted(ii,1) ;
        to_compare = imcrop(xcorr,[all_maxs_sorted(ii,2) - ...
                            floor(size(cone,2)/2) , all_maxs_sorted(ii,1) -...
                            floor(size(cone,1)/2) , floor(size(cone,2)) ...
                            floor(size(cone,1))]);

        [duplicates, row_indices] = setdiff(all_maxs_sorted(:,3),to_compare(:));
        all_maxs_sorted_new = sortrows(all_maxs_sorted(row_indices,:),-3);
        all_maxs_sorted = all_maxs_sorted_new;
        jj = jj + 1;

        size(all_maxs_sorted,1)
        if isempty(all_maxs_sorted)
            break
        end

    end
    
    jj=1;
    for ii = 1:length(x_interest)
        if ( (x_interest (ii) > (rect_x - 3)) && ...
            (x_interest (ii) < (rect_x+ rect_w + 3)) && ...
            (y_interest(ii) > (rect_y-3)) && ...
            (y_interest(ii) < (rect_y+ rect_h + 3)) )
        
            offset_cropped(jj,:) = [x_interest(ii,1), y_interest(ii,1)];
            jj=jj+1;
            else 
        end
    end
                          
    h = figure(259); 
    imshow(img_crop,'InitialMagnification', 500, 'Border', 'Tight')
    colormap(gray); 
    caxis([min(img_crop(:)),max(img_crop(:))]);
    rectangle('Position',rect_position, 'EdgeColor', 'r'); hold on,
    axis equal, axis off;
    for ii = 1:size(offset_cropped,1)
       text(offset_cropped(ii,1),offset_cropped(ii,2),[num2str(ii)],...
            'Color','b','FontWeight','bold')
    end
    hold off;   
    
    choice = questdlg('Accept cone selections ?', ...
     'Auto or manual cone selection', ...
     'Yes','Switch to Manual','Yes');

    switch choice
        case 'Switch to Manual'
          close 259;  
          [img_map, offset_cropped] =  cone_select.manual_cone_select(...
              img_crop,rect_position);

        case 'Yes'
          img_map = frame2im(getframe(h));
          close 259;
    end