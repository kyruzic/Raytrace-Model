function [pathData, pathVec] = gridInterp(path, radGrid, dimensions) 
% Name:
%     gridInterp
%
% Author:
%     Kyle Ruzic
%
% Date:
%     August 24th 2018
%
% Purpose:
%     Creates an interpolant grid based upon the modelled grid
%     passed to it, and queries the points in the interpolant
%     structure defined by the path. The path is transformed from
%     units of lat/lon/alt to 'grid' units. 
%   
% Inputs:
%     path       - path of cassiope loaded from data file
%     radGrid    - generated model  
%     dimensions - A structure containing the dimensions for which the model
%                  will be produced, it should be in this form:
%                  
%                  dimensions.range = [minLat, maxLat, minLon, maxLon, minAlt, maxAlt]; 
%                  dimensions.spacing = [numLat, numLon, numAlt];
%         .range     - Contains the ranges for which the model will
%                      be generated        
%         .spacing   - more aptly named size, contains sizes of
%                      each dimension


    radGrid = radGrid(:,:,:,1); % removing the second dimension as
                                % it isn't used currently, when
                                % pointing direction of ray is
                                % included this line will need to
                                % be removed
   
    
    % puts the size of the model grid into a grid format, this is
    % needed to be done in order to create the interpolant structure
    latVec = [1:size(radGrid, 1)];
    lonVec = [1:size(radGrid, 2)];
    altVec = [1:size(radGrid, 3)];

    % creates grid of size data for generating interpolant 
    [latGrid, lonGrid, altGrid] = ndgrid(latVec, lonVec, altVec);

    % a gridded interpolant structure that can be queried at positions
    F = griddedInterpolant(latGrid, lonGrid, altGrid, radGrid); 
    
    PathVec = transformPath(path, Dimensions); 
    
    % retrives the interpolated values at the points 
    pathData = F(PathVec.lat, PathVec.lon, PathVec.height);


    
    

    
    
