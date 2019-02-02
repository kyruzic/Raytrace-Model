function ray = rangeApplier(ray, range)
    
    maxlat = range(2);
    minlat = range(1);       
    maxlon = range(4);
    minlon = range(3);
    maxheight = range(6);
    minheight = range(5);

    for i = 1:length(ray)
        
        ray(i).lon = ray(i).lon + 181; % changes format of lon from -180 -180 to 0-360 
        ray(i).lat = ray(i).lat + 91; % 1 to 180 degrees due to matlab arrays index starting at 1
        ray(i).height = ray(i).height + 1; % again matlab arrays start at 1 not 0   
        
        ray(i).lat(isnan(ray(i).lat)) = []; % occasionally a pharlap ray trace would contain NaN values 
        ray(i).lon(isnan(ray(i).lon)) = []; % these lines remove those values, thankfully when they occured 
        ray(i).height(isnan(ray(i).height)) = []; % all related data also contains NaN, so if ray(i).lat(j) 
        ray(i).group_range(isnan(ray(i).group_range)) = []; % was NaN so was ray(i).lon(j) and so on

        % We only care about the lats/lons/heights in our range, so we can
        % get rid of the rest
        lat = ray(i).lat;
        lon = ray(i).lon;
        height = ray(i).height;
        group_range = ray(i).group_range;
        
        % phase_path = ray(i).phase_path;         
        
        indicies = gt(lat, maxlat);
        lat(indicies) = [];
        lon(indicies) = [];
        height(indicies) = [];
        group_range(indicies) = [];
        
        indicies = lt(lat, minlat);
        lat(indicies) = [];
        lon(indicies) = [];
        height(indicies) = [];
        group_range(indicies) = [];
        % phase_path(indicies) = [];
        
        indicies = gt(lon, maxlon);
        lat(indicies) = [];
        lon(indicies) = [];
        height(indicies) = [];
        group_range(indicies) = [];
        % phase_path(indicies) = [];
        
        indicies = lt(lon, minlon);   
        lat(indicies) = [];
        lon(indicies) = [];
        height(indicies) = [];
        group_range(indicies) = [];
        % phase_path(indicies) = [];
        
        indicies = gt(height, maxheight);
        lat(indicies) = [];
        lon(indicies) = [];
        height(indicies) = [];     
        group_range(indicies) = [];
        % phase_path(indicies) = [];
        
        indicies = lt(height, minheight);
        lat(indicies) = [];
        lon(indicies) = [];
        height(indicies) = [];
        group_range(indicies) = [];
        % phase_path(indicies) = [];

        % now put the lat in the correct format (minlat needs to be bin 1) 
        lat = lat - minlat;
        lon = lon - minlon;
        height = height - minheight;
        
        ray(i).lat = lat;
        ray(i).lon = lon;
        ray(i).height = height;   
        ray(i).group_range = group_range;
        % ray(i).phase_path = phase_path;
    end
