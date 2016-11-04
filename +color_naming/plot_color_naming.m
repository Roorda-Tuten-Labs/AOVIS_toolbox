function plot_color_naming(AllData)

%%%%%%%% Plot the output %%%%%%%%%%%
temp = [AllData.coneids, AllData.intensities, AllData.answer];
% sort rows so that organized by cone ID. (i.e. cone#1, cone#2 ...);
sortrows(temp,1);

figure();
if AllData.Nscale == 1
    for loc_index = 1:AllData.num_locations
       subplot(ceil(AllData.num_locations/3), 3, loc_index); 

       cone = temp(temp(:, 1) == loc_index, 3);

       C = categorical(cone, 1:5, AllData.cnames);
       histogram(C, 'Normalization', 'probability');

       set(gca, 'FontSize', 15);      
       title(['#', num2str(loc_index) '; N seen: ' num2str(sum(cone < 6))]); 

    end
else
    
    % plot uad diagram here for each cone
    for loc_index = 1:AllData.num_locations
        % set the subplot
        subplot(ceil(AllData.num_locations / 3), 3, loc_index); 

        % select out individual cone's data
        cone = temp(temp(:, 1) == loc_index, 3:end);

        % remove rows with all zeros
        cone = cone(any(cone, 2), :);

        % compute the frequency of seeing
        FoS = round(size(cone, 1) / AllData.ntrials, 3);

        title_text = ['#', num2str(loc_index) '; FoS: ' num2str(FoS)];
        
        % plot response data for cone on Uniform Appearance Diagram
        plots.plot_uad(cone, title_text, 10, 13);

    end
    
end
