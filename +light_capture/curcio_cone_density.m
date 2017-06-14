function cones_per_unit = curcio_cone_density(eccentricity, meridian, ...
                                             units)
    % cones_per_unit = curcio_cone_density(eccentricity, meridian, units)
    % -------------------------------------------------------------------
    % PARAMETERS
    % eccentricity = retinal location. units specified in 'units'
    % parameter.
    %
    % meridian = retinal meridian to consider in calculation. Can be
    % superior, inferior, temporal, nasal or a mean of all 4.
    %
    % units = mm or deg. This is the unit that both eccentricity must be
    % specified and that results will be return in. 
    %
    % For example, the density of cones at 1 mm will return a value in 
    % cones/mm^2.
    % -------------------------------------------------------------------
    %
    % NOTES FROM CURCIO 
    % File: Curcio1\..Documents\ PublishedProjects\ Prtopography\ 123\
    % 4meridians.xls
    % Created: 10/12/2003 by cc
    % Last modified: 6/2/2006 by cc
    % Purpose: to summarize in one file the data used for Figures 6 & 9 ...
    %        of Curcio et al., JCompNeurol 292:497 (1990)
    % Comment: 
    % In the sheets called Horizontal Meridian and Macula, negative ...
    %     eccentricities refer to the nasal horizontal meridian.
    % In the sheets called Cones per sq mm and Rods per sq mm, eccentricity ...
    %     in degrees was calculated using the Drasdo & Fowler schematic ...
    %     (275 µm/degree)
    % -------------------------------------------------------------------
    
    if nargin < 1
        eccentricity = 2;
    end
    if nargin < 2
        meridian = 'mean';
    end
    if nargin < 3
        units = 'deg';
    end
    
    fileID = fopen('curcio_conedensity_1990.csv');
    headers = textscan(fileID, '%s %s %s %s %s %s', 1, 'delimiter', ',');
    data = textscan(fileID, '%f %f %f %f %f %f', 'delimiter', ',');
    fclose(fileID);
    
    mm_from_fovea = data{1};

    superior = data{3};
    inferior = data{4};
    temporal = data{5};
    nasal = data{6};
    
    if strcmp(units, 'deg')
        superior = mm2_to_deg2(mm_from_fovea, superior);
        inferior = mm2_to_deg2(mm_from_fovea, inferior);
        temporal = mm2_to_deg2(mm_from_fovea, temporal);
        nasal = mm2_to_deg2(mm_from_fovea, nasal);
    end
    % Watson (2014) wasn't happy with Drasdo & Fowler (1974) model eye
    % conversion so he defined his own from their data. Curcio in her
    % spreadsheet reported a conversion from the Drasdo & Fowler model
    % eye. So first thing we need to do is convert using Watson's method.
    deg = mm_to_deg(mm_from_fovea);
    
    % decide which meridian along the retina to use
    if strcmp(meridian, 'superior')
        density = superior;
    elseif strcmp(meridian, 'inferior')
        density = inferior;
    elseif strcmp(meridian, 'temporal')
        density = temporal;
    elseif strcmp(meridian, 'nasal')
        density = nasal;
    elseif strcmp(meridian, 'mean') || strcmp(meridian, 'average')
        density = nanmean([superior, inferior, temporal, ...
                           nasal], 2);
    else
        error(['Meridian not understood. Use ''superior'' ''inferior'' ' ...
               '''temporal'' ''nasal'' or ''mean''']);
    end
    
    % now we can fit the data to yield an estimate for any meridian on
    % the retina.
    if strcmp(units, 'deg')
        cones_per_unit = spline(deg, density, eccentricity);
    elseif strcmp(units, 'mm')
        cones_per_unit = spline(mm_from_fovea, density, eccentricity);
    else
        error('unit must be deg or mm');
    end

    plot_degree_conv_sanity_check = 0;
    if plot_degree_conv_sanity_check
        deg_curcio = data{2}; % from the curcio data
        figure();
        plot(deg, deg_curcio);
        ylabel('Watson degrees');
        xlabel('Linear degrees');
    end

end