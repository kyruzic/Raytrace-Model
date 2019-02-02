function radGrid = rayCaller(date, time, dimensions, myFolder, dateFolder, dateFile)
% Name:
%     rayCaller
%
% Author:
%     Kyle Ruzic
%
% Date:
%     August 29th 2018
%
% Version:
%     1.0 
%
% Purpose:
%     Call rays that will be used to compute model, as well as creates
%     the initial model structure, a 4D (i*j*k*2) matrix. The
%     (i,j,k,1) position of the matrix contains power values
%     corresponding to i,j,k, which represent the latitude,
%     longitude, and altitude respectively. The (i,j,k,2) value
%     will be used in the future to store the pointing direction of
%     the ray, which is needed for more accurate comparisions to
%     RRI oberservations to be made.
%
% Calling Sequence:
%     This function cannot be used without first generating an
%     ionosphere, to do that either the function 'genIono' must
%     have been used to save the Ionosphere model. This model is
%     loaded by providing date and time inputs for when the model
%     is being produced for.
%   
%     
%     gen_iono(date, hour, myFolder, dateFolder, minute)
%
%     radGrid = rayCaller(date, hour, dimensions, myFolder, dateFolder, dateFile);
%
%     An example that illustrates how to use the model from start
%     to finish is also included
%
% Inputs:
%     date, time - These are used to find where the ionosphere is
%                  saved
%     dimensions - A structure containing the dimensions for which the model
%                  will be produced, it should be in this form:
%                  
%                  dimensions.range = [minLat, maxLat, minLon, maxLon, minAlt, maxAlt]; 
%                  dimensions.spacing = [numLat, numLon, numAlt];
%
%     myFolder   - The folder where the data files are stored 
%     dateFolder - date specific data folder 
%     dateFile   - A string of the date, eg. '26-June-2015'. Used
%                  in the file name of the saved data
% Outputs:
%     radGrid   - The finished model, a 3D (i*j*k) matrix of power values
    
    
    modelGen = true;  %corresponding ray trace plots
   
    clear iono_struct radGrid ray_O

    ionoString = strrep('DATE-TIMEUT.mat', 'DATE', ...
                         dateFile);
    ionoString = strrep(ionoString, 'TIME', num2str(time));
    ionoString = fullfile('iono_grid_dat', ionoString);
    ionoPath = fullfile(dateFolder, ionoString);

    % loads pregenerated iono grid and initial variables
    tic
    generalStructPath = 'gen_struct.mat';
    generalStruct = load(generalStructPath);
    iono_struct = load(ionoPath);

    % converts plasma frequency grid to electron density grid in electrons/cm^3
    iono_struct.en_grid = iono_struct.pf_grid.^2 / 80.6164e-6;
    iono_struct.en_grid_5 = iono_struct.pf_grid_5.^2 / 80.6164e-6;

    % These are not used by the program and take up huge amounts of
    % memory so they can be safely cleared
    iono_struct.pf_grid = 0; 
    iono_struct.pf_grid_5 = 0;

    % creates an initial ray structure
    nhops = 4;                  % number of hops
    tol = [1e-8 0.01 1];       % ODE solver tolerance and min max stepsizes
    OX_mode = 1;               % use 1 for O-mode and -1 for X-mode

    
    % gets data supplied by superdarn team

    % these are arrays with the first position being when the 
    % generates initial power grid

    radGrid = zeros(dimensions.spacing(1), dimensions.spacing(2) , dimensions.spacing(3), 2);
    NRT_total_time = 0;
    gridSize = size(radGrid);
    
    
    % data supplied by superDARN team
    gainDat = getGain('dat/SuperDARN_sas_11MHz_boresight.dat');
    gain = zeros(1,360);

    %calculating the total number of rays that will be traced
    angleSpacing = 0.1;
    bearingsArray = [0:angleSpacing:80,245:angleSpacing:360];
    elevsArray = [10:angleSpacing:90];
    numRays = length(elevsArray)*length(bearingsArray);
    
    % splits the bearings up into ten arrays, since the ray tracer
    % can't handle tracing all of the rays at the same time
    
    bearingCount = 1;
    num = round(length(bearingsArray)/10);
    init_ray.ray_bears = (bearingsArray(1:bearingCount*num));
    init_ray.freq  = ones(size(init_ray.ray_bears))*11;
    init_ray.elevs = ones(size(init_ray.ray_bears))*(1);

    [~, ~, ~] = ... % passing in iono_grid this is done to greatly increase the speed of the program
        raytrace_3d_sp(generalStruct.origin_lat, generalStruct.origin_long, generalStruct.origin_ht, ...
                       init_ray.elevs, init_ray.ray_bears, init_ray.freq, OX_mode, nhops, tol, generalStruct.re, ...
                       iono_struct.en_grid, iono_struct.en_grid_5, iono_struct.collision_freq, ...
                       iono_struct.iono_grid_parms, iono_struct.Bx, iono_struct.By, iono_struct.Bz, ...
                       iono_struct.geomag_grid_parms); % ray trace

    while bearingCount < 11
        
        % splits bearings array into to 1/10ths but has to check
        % for arrays not divisible by 10 to properly split them
        
        if bearingCount == 10 % incase initial array wasn't
                              % divisible by 10
            init_ray.ray_bears = bearingsArray((bearingCount-1)* ...
                                               num:end);
        else            
            init_ray.ray_bears = (bearingsArray(((bearingCount-1)*num)+1:bearingCount*num));
        end
        % changes size of freq and bearings array to ensure they
        % are the same size 
        init_ray.freq  = ones(size(init_ray.ray_bears))*11;
        init_ray.elevs = ones(size(init_ray.ray_bears))*(1);        
        
        for j = 10:angleSpacing:90
            current_elevation_angle = j
            start = round(j)+182;
            finish = 360*181-(180-(round(j)));
            interval = 181; % gets line number for gain file
                            % according to current elevation angle 

            gain(1) = gainDat(round(j+1),4);
            gain(2:360) = gainDat(start:interval:finish,4); 
            
            init_ray.elevs = ones(size(init_ray.ray_bears))*(j);
            [~, ray, ~] = raytrace_3d_sp(generalStruct.origin_lat, ... % calls raytracer 
                                           generalStruct.origin_long, generalStruct.origin_ht, init_ray.elevs, ...
                                           init_ray.ray_bears, init_ray.freq, OX_mode, nhops, tol, generalStruct.re);
            
            radGrid = powerCalc_phase(ray, radGrid, init_ray, gain, dimensions);% calling gridding function
            toc
            NRT_total_time = NRT_total_time + toc; 
            % tracks computation time
            tic            
        end
        bearingCount = bearingCount + 1;        

    end
    radGrid = radGrid.^2; 
    
    % Calculating what percentage of the sphere was filled with rays
    % this is used to correctly calculate the power that each ray
    % has
    bearingsPercent = length(bearingsArray)/(1/angleSpacing*360);
    elevationsPercent = length(elevsArray)/(1/angleSpacing*180);
    spherePercent = bearingsPercent * elevationsPercent;
    radGrid = radGrid .* spherePercent;
    
    radGridString = strrep('rad-grid_DATE-NUMUT_range','DATE', ...
                           dateFile);
    radGridString = strrep(radGridString, 'NUM', num2str(time));
    radGridPath = fullfile(dateFolder, radGridString);
    fprintf('\n Time of model generation %f\n\n', NRT_total_time) 
    save(radGridPath, 'radGrid', '-v7.3'); 
    % the files are sometimes over 2GB so you need to have the v7.3 
    clear ray_O iono_struct
    
end
    
    
