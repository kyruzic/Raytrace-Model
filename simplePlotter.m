function simplePlotter(radGrid, dimensions, UT, slices, path) 
% Produces plots of the generated model for specified elevation
% slices 
%
% Inputs:
% radGrid    - the previously generated model
% dimensions - structure containing size of the model
% UT         - time and date for which the model was generated
%
% Optional Inputs:
% slices     - Elevation slices for which the plots will be produced,
%              can be passed as either a single integer or an array
%              of integers.
% path       - the path of the Cassiope track, used to plot the path
%              over the model. Must be in grid units not lat/lon/alt.
%              To convert use the function transformPath
    

    date = general_struct.UT(1:3);
    time = general_struct.UT(4);
    dateFile = datestr(date, 'dd-mmmm-yyyy')
    num = time;
    
    if nargin < 4 % neither optional inputs are passed, so set them
                  % to default values 
        slices = [100, 200, 250]; 
        path.lat = [];
        path.lon = [];        
    elseif nargin < 5 % path was not passed set to default    
        path.lat = [];
        path.lon = [];
    end
        

    dimensions.size = dimensions.spacing;
    spacingLon = ((dimensions.range(4) - dimensions.range(3))/ ...
                  dimensions.size(2));
    degLon = (dimensions.size(2) *  spacingLon);

    spacingLat = ((dimensions.range(2) - dimensions.range(1))/ ...
                  dimensions.size(1));
    degLon = (dimensions.size(1) *  spacingLon);
    
    
    % radGrid(radGrid > 1) = nan; 
    radGrid(radGrid == 0) = nan;

   
    for slice = slices
        figure
        clf % clears figure so the figure doesn't pop up and
            % become the focused windowed

        colormap parula
        sliceVar = round(slice/8);

        hold on

        h = pcolor(log10(radGrid(:,:,sliceVar)));
        shading interp


        b = colorbar;
        % caxis([-20 0])
        titleString = strrep(['at a Height of SLICEkm DATE ' ...
                            'VAR-UT'],'VAR',num2str(num));
        
        titleString = strrep(titleString,'SLICE', ...
                             num2str(slice));
        titleString = strrep(titleString, 'DATE', dateFile);
        title({['Modelled SuperDARN Saskatoon Beam 7 Radiation ' ...
                'at 11MHz'], titleString}, 'FontSize', 22)
        colorTitleHandle = get(b,'Title');
        titleString = 'log_{10}(\mu W/m^{2})';
        set(colorTitleHandle ,'String',titleString);

        
        xticks(4:10*round(1/spacingLon):dimensions.size(2));
        yticks(4:5*round(1/spacingLat):dimensions.size(1));
        xticklabels(dimensions.range(3)-180:10:dimensions.range(4)-180);
        yticklabels(dimensions.range(1)-90:5:dimensions.range(2)-90);
        xlabel("Longitude (degrees)", 'FontSize', 20)
        ylabel("Latitude (degrees)", 'FontSize', 20)
        
        set(h, 'edgecolor', 'none');
        set(gcf, 'InvertHardcopy', 'off');
        set(gcf, 'PaperUnits', 'inches');
        set(gcf, 'Color', 'w');
        
        hold on
        plot(path.lon, path.lat, 'r.')
        hold off
    end

