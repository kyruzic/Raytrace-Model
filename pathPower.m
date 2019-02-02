function pathPower(dateFile, time, myFolder, cassiopeFile, radGrid, dimensions)
% Name:
%     pathPower
%
% Author:
%     Kyle Ruzic
%
% Date:
%     August 24th 2018
%
% Purpose:
%     Generates a plot of the power along a given Cassiope track by
%     calling the functions pathGen and pathPlotter. This also
%     loads the RRI dat file, which contains location and
%     measurement data.
%
% Inputs:
%     date, time   - used to find previously saved generated model
%     myFolder     - location of the dat folder
%     cassiopeFile - location of the file with the Cassiope path data,
%                    if the file is not in the same directory include
%                    the entire path
%     dimensions - A structure containing the dimensions for which the model
%                  will be produced, it should be in this form:
%                  
%                  dimensions.range = [minLat, maxLat, minLon, maxLon, minAlt, maxAlt]; 
%                  dimensions.spacing = [numLat, numLon, numAlt];
%         .range     - Contains the ranges for which the model will
%                      be generated        
%         .spacing   - more aptly named size, contains sizes of
%                      each dimension
    
    dateFile2 = datestr(datenum(dateFile, 'dd-mmmm-yyyy'), 'yyyy-mm-dd');
    idlDat = strrep('CASSIOPE-dat/RRI_REPLACE_*.sav', 'REPLACE', dateFile2);
    idlDat = dir(idlDat); % this just autocompletes the star, which
                          % contains time information  
    idlDat = fullfile('CASSIOPE-dat', idlDat.name);

    epop_dat=restore_idl(idlDat,'lowercase','true');  
    
    path = pathGen(cassiopeFile);
    pathVec = pathPlotter(path, dateFile, time, myFolder, radGrid, dimensions)
    
    simplePlotter(radGrid, myFolder, dateFile, time, dimensions, [100, 200, 1350], pathVec)