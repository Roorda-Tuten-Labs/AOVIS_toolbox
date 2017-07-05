function plot_color_naming(AllData, single_plot, format_axes, save_plots)

if nargin < 2
    single_plot = 0;
end
if nargin < 3
    format_axes = 1;
end
if nargin < 4
    save_plots = 0;
end

%%%%%%%% Plot the output %%%%%%%%%%%
temp = [AllData.coneids, AllData.intensities, AllData.answer];

% video folder where plots will be saved. first 14 chars are "Video Folder:"
videofolder = AllData.videofolder(15:end);

% sort rows so that organized by cone ID. (i.e. cone#1, cone#2 ...);
sortrows(temp,1);

ntrials = size(AllData.answer, 1) / AllData.num_locations;
% need to add not seen category
cnames = {'n.s.', AllData.cnames{:}};
if AllData.Nscale == 1
    fig1 = figure;
    for loc_index = 1:AllData.num_locations
        subplot(ceil(AllData.num_locations / 3), 3, loc_index); 

        cone = temp(temp(:, 1) == loc_index, 3);       

        C = categorical(cone, 0:5, cnames);
        histogram(C, 'Normalization', 'probability');

        xlim([-0.5, 7.0]);
        ylim([0 1]);
        set(gca, 'FontSize', 12);            
        title(['#', num2str(loc_index) '; N seen: ' num2str(sum(cone < 6))]); 
        if save_plots
            savename = fullfile(videofolder, 'color_naming');
            plots.save_fig(savename, fig1, 1, 'eps');
        end        
    end
else
    
    intensities = unique(AllData.intensities);
    nintensities = length(intensities);
    ncones = length(unique(AllData.coneids));
    if nintensities > 1     
        fig1 = figure;
        clf;
        hold on;
        FoS_data = zeros(ncones, nintensities);
        for c = 1:ncones
            cone = AllData.brightness_rating(AllData.coneids == c);
            stim_intensities = AllData.intensities(AllData.coneids == c);
            for inten = 1:nintensities
                intensity = intensities(inten);
                intensity_trials = stim_intensities == intensity;
                seen = sum(cone(intensity_trials) > 1);
                trials = sum(intensity_trials);
                FoS_data(c, inten) = seen / trials;
            end
        end
        % 
        blankFoS = mean(FoS_data(:, 1));
        % threshold estimates
        thresholds = zeros(ncones, 1);
        for c = 1:ncones
            % use the mean of all blanks to avoid issues with low number of
            %  trials
            coneFoS = [blankFoS FoS_data(c, 2:end)];

            plot(intensities, coneFoS, 'ko', 'color', 'k');

            % fit a psychometric function
            results.intensity = intensities';
            results.response = coneFoS;
            pInit.b = 0.1;
            pInit.t = 0.5;        
            pBest = stats.fit_psychometric_func(results, pInit, 'k');
            
            text(pBest.t, 0.5, num2str(c), 'FontSize', 16);

            thresholds(c) = pBest.t;
        end
        plots.nice_axes('stimulus intensity (a.u.)', ...
            'frequency of seeing', 20);
        if save_plots
            savename = fullfile(videofolder, 'FoS_plot');
            plots.save_fig(savename, fig1, 1, 'eps');
        end        
        
    end
    
    fig = figure;
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
            
            % compute the frequency of seeing or use threshold from above
            if exist('thresholds', 'var')
                FoS = thresholds(loc_index);
                title_text = ['50% FoS: ' num2str(round(FoS, 2))];
            else
                FoS = round(size(cone, 1) / ntrials , 3);
                title_text = ['#', num2str(loc_index) '; FoS: ' ...
                    num2str(FoS)];
            end
            
        end
        
        % plot response data for cone on Uniform Appearance Diagram
        plots.plot_uad(cone, title_text, 10, 12, format_axes);     
    end                
    if save_plots
        savename = fullfile(videofolder, 'hue_scaling');
        plots.save_fig(savename, fig, 1, 'eps');
    end   

end
