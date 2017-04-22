function [img_map, offsets_manual] = manual_cone_select(img_crop,rect_position,...
                                                      rect_position_old)
    
    Redo = 1;
    while Redo
 
        h = figure (259);
        hold on;
        imshow(img_crop,'InitialMagnification', 500, 'Border', 'Tight')
        colormap(gray); 
        % caxis([min(img_crop(:)),max(img_crop(:))]);

        rectangle('Position',rect_position, 'EdgeColor', 'r'); 
        if ~isnan(rect_position_old)
            rectangle('Position',rect_position_old, 'EdgeColor', ...
                      'w','LineStyle',':'); 
        end
        axis equal; 
        axis off;

        n = 1; 
        while 1
            % get user defined locations
            [x, y, clicks] = ginput(1);
            X(n,1)= round(x); 
            Y(n,1)= round(y);

            % add text to image to display cone locations
            text(X(n,1),Y(n,1),[num2str(n)],'Color','b','FontWeight','bold')
            
            n = n+1; % increment number of cones
            if clicks == 3 % Right click button terminates cone selection
                break
            end
            
        end
        hold off;
        
        % ask user whether the accept cone selections or retry.
        choice = questdlg('Accept cone selections ?', ...
                          'Manual cone selection', ...
                          'Yes','Redo','Yes');
        
        % either end or redo cone selections
        switch choice
          case 'Redo'
            Redo = 1;
            close 259
          case 'Yes'
            Redo = 0;
            img_map = frame2im(getframe(h));
            [offsets_manual] = [X,Y];
            close 259;
        end
        
    end

        