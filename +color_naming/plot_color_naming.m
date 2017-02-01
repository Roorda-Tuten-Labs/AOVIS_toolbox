function plot_color_naming(AllData, single_plot, format_axes, figh)

if nargin < 2
    single_plot = 0;
end
if nargin < 3
    format_axes = 1;
end
if nargin < 4
    figure();
end

%%%%%%%% Plot the output %%%%%%%%%%%
temp = [AllData.coneids, AllData.intensities, AllData.answer];

% sort rows so that organized by cone ID. (i.e. cone#1, cone#2 ...);
sortrows(temp,1);

ntrials = size(AllData.answer, 1) / AllData.num_locations;

if AllData.Nscale == 1
    for loc_index = 1:AllData.num_locations
       subplot(ceil(AllData.num_locations / 3), 3, loc_index); 

       cone = temp(temp(:, 1) == loc_index, 3);

       C = categorical(cone, 1:5, AllData.cnames);
       histogram(C, 'Normalization', 'probability');

       set(gca, 'FontSize', 15);      
       title(['#', num2str(loc_index) '; N seen: ' num2str(sum(cone < 6))]); 

    end
else
    
    % plot uad diagram here for each cone
    for loc_index = 1:AllData.num_locations
        
        % select out individual cone's data
        cone = temp(temp(:, 1) == loc_index, 3:end);

        % remove rows with all zeros
        cone = cone(any(cone, 2), :);

        if single_plot
            title_text = '';
        else
            
            % set the subplot
            subplot(ceil(AllData.num_locations / 3), 3, loc_index); 
            
            % compute the frequency of seeing
            FoS = round(size(cone, 1) / ntrials , 3);

            title_text = ['#', num2str(loc_index) '; FoS: ' num2str(FoS)];
            
        end
        
        % plot response data for cone on Uniform Appearance Diagram
        plots.plot_uad(cone, title_text, 10, 13, format_axes);

    end
    

end
