function test_curcio_cone_density()

    fileID = fopen('curcio_conedensity_1990.csv');
    textscan(fileID, '%s %s %s %s %s %s', 1, 'delimiter', ',');
    data = textscan(fileID, '%f %f %f %f %f %f', 'delimiter', ',');
    fclose(fileID);
    
    mm_from_fovea = data{1};
    degrees = data{2};
    
    superior = curcio_cone_density(mm_from_fovea, 'superior', 'mm');
    inferior = curcio_cone_density(mm_from_fovea, 'inferior', 'mm');
    temporal = curcio_cone_density(mm_from_fovea, 'temporal', 'mm');
    nasal = curcio_cone_density(mm_from_fovea, 'nasal', 'mm');

    superior_deg = curcio_cone_density(degrees, 'superior', 'deg');
    inferior_deg = curcio_cone_density(degrees, 'inferior', 'deg');
    temporal_deg = curcio_cone_density(degrees, 'temporal', 'deg');
    nasal_deg = curcio_cone_density(degrees, 'nasal', 'deg');

    plot_curcio_data = 1;
    plot_spline_interp = 1;
    
    if plot_spline_interp
        xx = logspace(-1, 2, 50);
        yy = spline(degrees, superior, xx);
        figure();
        loglog(degrees, superior, 'ko'); hold on;
        loglog(xx, yy, 'r-');
        %ylim([100, 200000]);
        
        xlabel('eccentricity (degrees)');
        ylabel(['density (cones/mm^2)']);
        
    end
    
    if plot_curcio_data
        % unprocessed data
        figure();
        loglog(mm_from_fovea, superior, 'b'); hold on;
        loglog(mm_from_fovea, inferior, 'k');
        loglog(mm_from_fovea, temporal, 'r');
        loglog(mm_from_fovea, nasal, 'g');
        
        legend('superior', 'inferior', 'temporal', 'nasal');
        %ylim([100, 200000]);
        
        xlabel('eccentricity (mm)');
        ylabel('density (cones/mm^2)');
        
        % compare to Watson Fig 1. He screwed up his labels.
        figure();
        loglog(degrees, superior_deg, 'b'); hold on;
        loglog(degrees, inferior_deg, 'k');
        loglog(degrees, temporal_deg, 'r');
        loglog(degrees, nasal_deg, 'g');
        
        legend('superior', 'inferior', 'temporal', 'nasal');
        %ylim([100, 200000]);
    
        xlabel('eccentricity (degrees)');
        ylabel(['density (cones/deg^2)']);
    end
    