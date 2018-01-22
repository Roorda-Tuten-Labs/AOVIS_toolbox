function[stim_im] = createStimulus(stimsize, stimshape, imsize)    

    stim_im = zeros(imsize, imsize);
    if strcmpi(stimshape, 'square')
        stim_im = zeros(imsize,imsize);
       center = imsize/2;
        if (stimsize/2)~=round(stimsize/2) %stimsize odd
            stim_im(center-((stimsize-1)/2):center+((stimsize-1)/2),center-((stimsize-1)/2):center+((stimsize-1)/2)) = 1;
        elseif (stimsize/2)==round(stimsize/2) %stimsize even
            stim_im(center-((stimsize)/2):center+((stimsize/2)-1),center-((stimsize)/2):center+((stimsize/2)-1)) = 1;
        else
            %do nothing
        end        
    elseif strcmpi(stimshape, 'circle')
        if (stimsize/2)~=round(stimsize/2) %stimsize odd
            armlength = (stimsize-1)/2;
            center = imsize/2;
            for radius = 1:armlength
                theta = (0:0.001:2*pi);
                xcircle = radius*cos(theta)+ center; ycircle = radius*sin(theta)+ center;
                xcircle = round(xcircle); ycircle = round(ycircle);
                nn = size(xcircle); nn = nn(2);
                xymat = [xcircle' ycircle'];
                for point = 1:nn
                    row = xymat(point,2); col2 = xymat(point,1);
                    stim_im(row,col2)= 1;
                end
            end
            stim_im(center, center)=1;        
            
        elseif (stimsize/2)==(round(stimsize/2)) %stimsize even
            stim_im = zeros(imsize+1, imsize+1);
            armlength = (stimsize)/2;
            center = (imsize+2)/2;
            for radius = 1:armlength
                theta = (0:0.001:2*pi);
                xcircle = radius*cos(theta)+ center; ycircle = radius*sin(theta)+ center;
                xcircle = round(xcircle); ycircle = round(ycircle);
                nn = size(xcircle); nn = nn(2);
                xymat = [xcircle' ycircle'];
                for point = 1:nn
                    row = xymat(point,2); col2 = xymat(point,1);
                    stim_im(row,col2)= 1;
                end
            end
            stim_im(center, center)=1;
            stim_im(center,:) = []; stim_im(:,center)=[];
        else %do nothing
            error('Stimulus shape not understood');
        end
        
    else  %do nothing
    end    
end