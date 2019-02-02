function path = pathGen(cassiopeDatPath)
% Loads Cassiope path data from supplied file, then interpolates the
% supplied data. The path is returned as a path structure, that includes
% path.lat, path.lon, and path.alt
%
% Inputs:
% cassiopeDatPath - Path to Cassiope data 

    pathData = importdata(cassiopeDatPath, ' ',2);
    
    path.lat = pathData.data(:, 12);
    path.lon = pathData.data(:, 13);
    path.alt = pathData.data(:, 14);

    templat = [];
    templon = [];
    tempalt = [];
    
    for i = 1:(length(path.lat)-2) %this needs to be improved with interpolation

        templat = [templat, linspace(path.lat(i), path.lat(i+1), 10)];
        templon = [templon, linspace(path.lon(i), path.lon(i+1), 10)];
        tempalt = [tempalt, linspace(path.alt(i), path.alt(i+1), 10)];
    end

    path.lat = templat;
    path.lon = templon;
    path.alt = tempalt;
