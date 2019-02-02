function PathVec = transformPath(path, Dimensions)
% Transforms path that is in the form of lat/lon/alt into the units
% of the power grid 
%
% This function is needed since the grid's indicies are not always 
% equal to lat/lon/alt so the path needs to be converted to these grid
% units. 
%
% Inputs:
% path       - the path of Cassiope
% Dimensions - struct containing the size, start and end points,
%              and spacing of radGrid. This file is saved when the
%              model is produced. 
    
    range = Dimensions.range;
    spacing = Dimensions.spacing; 
    Dimensions = []; 
    
    lats = path.lat + 90;
    lons = path.lon + 180;
    heights = path.alt;
    
    latFactor = spacing(1) / (range(2) - range(1));
    lonFactor = spacing(2) / (range(4) - range(3));
    heightFactor = spacing(3) / (range(6) - range(5));

    PathVec.lat = lats;
    PathVec.lon = lons;
    PathVec.height = heights; 
    PathVec.phase_path = heights; % I need the struct to have this field
    PathVec.group_range = [];                              % to use the function rangeApplier

    % PathVec = rangeApplier(PathVec, range); % this just gets rid of
                                            % the path outside of
                                            % the grid
    PathVec.lat = (PathVec.lat - range(1)) * latFactor; 
    PathVec.lon = (PathVec.lon - range(3)) * lonFactor;
    PathVec.height = (PathVec.height - range(5)) * heightFactor;
    

    % PathVec.lon
    
    
    
    
    
    