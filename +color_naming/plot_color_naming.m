function [fig1, fig2] = plot_color_naming(AllData, single_plot, ...
    format_axes, save_plots)
% [fig1, fig2] = plot_color_naming(AllData, single_plot, ...
%    format_axes, save_plots)
%

if nargin < 2 || isempty(single_plot)
    single_plot = 0;
end
if nargin < 3 || isempty(format_axes)
    format_axes = 1;
end
if nargin < 4
    save_plots = 0;
end

%%%%%%%% Plot the output %%%%%%%%%%%
if isfield(AllData, 'coneids')
    temp = AllData.coneids;
    ncones = length(unique(AllData.coneids));
    loc_ids = AllData.coneids;    
    pairs_flag = 0;
    temp = [temp, AllData.intensities, AllData.answer];
    
elseif isfield(AllData, 'location_ids')
    temp = AllData.combination_id;
    ncones = length(unique(AllData.combination_id));
    loc_ids = AllData.combination_id;
    pairs_flag = 1;
    temp = [temp, AllData.intensities, AllData.answer];
    
elseif isfield(AllData, 'intensity_ids')
    
    temp = AllData.intensity_ids;
    ncones = length(unique(AllData.intensity_ids));
    AllData.num_locations = ncones;
    loc_ids = AllData.intensity_ids;
    pairs_flag = 0;
    temp = [temp, AllData.intensity_ids, AllData.answer];    
end
    

% video folder where plots will be saved."
videofolder = AllData.videofolder;

% sort rows so that organized by cone ID. (i.e. cone#1, cone#2 ...);
sortrows(temp,1);

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
            plots.save_fig(savename, fig1, 1, 'pdf');
        end        
    end
else
    if isfield(AllData, 'intensities')
        intensities = unique(AllData.intensities);    
        nintensities = length(intensities);
        if sum(intensities > 0) > 2     
            fig1 = figure;
            clf;
            hold on;
            FoS_data = zeros(ncones, nintensities);
            for c = 1:ncones
                cone = AllData.brightness_rating(loc_ids == c);
                stim_intensities = AllData.intensities(loc_ids == c);
                for inten = 1:nintensities
                    intensity = intensities(inten);
                    intensity_trials = stim_intensities == intensity;
                    seen = sum(cone(intensity_trials) > 0);
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
                pInit.b = 4;
                pInit.t = 0.3;        
                pBest = psycho.fit_psychometric_func(results, pInit, 'k', [], ...
                    [], 'weibull');

                text(pBest.t, 0.5, num2str(c), 'FontSize', 16);

                thresholds(c) = pBest.t;
            end

            plots.nice_axes('stimulus intensity (a.u.)', ...
                'frequency of seeing', 14, [], 1);

            if save_plots
                savename = fullfile(videofolder, 'FoS_plot');
                plots.save_fig(savename, fig1, 1, 'pdf');
            end        

        end
    end
    fig2 = figure;
    % plot uad diagram here for each cone
    if pairs_flag
        nlocations = AllData.num_locations * 2;
    else
        nlocations = AllData.num_locations;
    end
    
    if single_plot
        plots.format_uad_axes(1, 1, '', 12);
    end    
    for loc_index = 1:nlocations
        
        % select out individual cone's data
        cone = temp(temp(:, 1) == loc_index, 3:end);
        
        % n trials for each cone
        ntrials = size(cone, 1);

        % remove rows with all zeros
        cone = array.remove_zero_rows(cone);
        
        % remove rows with all NAN (new way of inputing not seen)
        cone = array.remove_nan_rows(cone);

        if single_plot
            title_text = '';
        else
            
            % set the subplot
            subplot(ceil(ncones / 3), 3, loc_index); 
            
            % compute the frequency of seeing or use threshold from above
            if exist('thresholds', 'var')
                FoS = thresholds(loc_index);
                title_text = ['50% FoS: ' num2str(round(FoS, 2))];
            else
                FoS = round(size(cone, 1) / ntrials , 3);
                title_text = ['#', num2str(loc_index) '; FoS: ' ...
                    num2str(FoS)];
            end
            plots.format_uad_axes(1, 1, title_text, 12);
            
        end
        
        % plot response data for cone on Uniform Appearance Diagram
        plots.plot_uad(cone, title_text, 8, 12, 0);     
    end 

    if save_plots
        savename = fullfile(videofolder, 'hue_scaling');
        plots.save_fig(savename, fig2, 1, 'pdf');
    end   
    if nargout == 2 && ~exist('fig1', 'var')
        fig1 = [];
    end

end
