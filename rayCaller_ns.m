function radGrid = rayCaller_ns(dimensions, iono_struct, general_struct)
% Name:
%     rayCaller
%
% Author:
%     Kyle Ruzic
%
% Date:
%     August 30th 2018
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
%     gen_iono_ns(date, hour, minute)
%
%     radGrid = rayCaller_ns(date, hour, dimensions, iono_struct, general_struct);
%
%     An example that illustrates how to use the model from start
%     to finish is also included
%
% Inputs:
%     dimensions - A structure containing the dimensions for which the model
%                  will be produced, it should be in this form:
%                  
%                  dimensions.range = [minLat, maxLat, minLon, maxLon, minAlt, maxAlt]; 
%                  dimensions.spacing = [numLat, numLon, numAlt];
%
%     iono_struct
%         .pf_grid           - 3d grid (height vs lat. vs lon.) of ionospheric plasma
%                                  frequency (MHz)
%         .pf_grid_5         - 3d grid (height vs lat. vs lon.) of ionospheric plasma
%                                  frequency (MHz) 5 minutes later
%         .collision_freq    - 3d grid (height vs lat. vs lon.) of ionospheric
%                                  collision frequencies
%         .Bx                - 3d grid of x component of geomagnetic field
%         .By                - 3d grid of y component of geomagnetic field
%         .Bz                - 3d grid of z component of geomagnetic field
%         
%         .iono_grid_parms   - 9x1 vector containing the parameters which define the
%                       
%           ionospheric grid :
%           (1) geodetic latitude (degrees) start
%           (2) latitude step (degrees)
%           (3) number of latitudes
%           (4) geodetic longitude (degrees) start
%           (5) lonitude step (degrees)
%           (6) number of longitudes
%           (7) geodetic height (km) start
%           (8) height step (km)
%           (9) number of heights
%
%         .geomag_grid_parms - 9x1 vector containing the parameters which define the
%   
%           geomagnetic grid :
%           (1) geodetic latitude (degrees) start
%           (2) latitude step (degrees)
%           (3) number of latitudes
%           (4) geodetic lonitude (degrees) start
%           (5) lonitude step (degrees)
%           (6) number of longitudes
%           (7) geodetic height (km) start
%           (8) height step (km)
%           (9) number of heights
%
%     general_struct - contains general information that is used
%                      for ray tracing
%         .UT                - 5x1 array containing UTC date and time - year, month,
%                                  day, hour, minute
%         .speed_of_light    - speed of light
%         .re                - radius of the Earth
%         .R12               - R12 index 
%         .origin_lat        - origin latitude of rays to be
%                              traced, this should be the location
%                              of the radar. 
%         .origin_long       - origin longitude
%         .origin_ht         - origin height
% Outputs:
%     radGrid   - The finished model, a 3D (i*j*k) matrix of power values
    
   
    % loads pregenerated iono grid and initial variables
    tic

    % converts plasma frequency grid to electron density grid in electrons/cm^3
    iono_struct.en_grid = iono_struct.pf_grid.^2 / 80.6164e-6;
    iono_struct.en_grid_5 = iono_struct.pf_grid_5.^2 / 80.6164e-6;

    % These are not used by the program and take up huge amounts of
    % memory so they can be safely cleared
    iono_struct.pf_grid = 0; 
    iono_struct.pf_grid_5 = 0;

    % creates an initial ray structure
    nhops = 4;                  % number of hops
    tol = [1e-8 0.01 10];       % ODE solver tolerance and min max stepsizes
    OX_mode = 1;               % use 1 for O-mode and -1 for X-mode

    
    % gets data supplied by superdarn team

    % these are arrays with the first position being when the 
    % generates initial power grid

    radGrid = zeros(dimensions.spacing(1), dimensions.spacing(2) , dimensions.spacing(3), 2);
    NRT_total_time = 0;
    gridSize = size(radGrid);
    
    
    % data supplied by superDARN team
    gainDat = general_struct.gain_dat;
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

    [~, ~, ~] = ... % passing in iono_grid, this is done to greatly increase the speed of the program
        raytrace_3d_sp(generalStruct.origin_lat, generalStruct.origin_long, generalStruct.origin_ht, ...
                       init_ray.elevs, init_ray.ray_bears, init_ray.freq, OX_mode, nhops, tol, generalStruct.re, ...
                       iono_struct.en_grid, iono_struct.en_grid_5, iono_struct.collision_freq, ...
                       iono_struct.iono_grid_parms, iono_struct.Bx, iono_struct.By, iono_struct.Bz, ...
                       iono_struct.geomag_grid_parms);
    
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
    radGrid = radGrid(:,:,:,1)
    
end
    
    
