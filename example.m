% Purpose:
%     Example of how to generate model from start to finish. This
%     is intended to be a basic use example, more information
%     regarding the functions used in this example can be found in
%     their respective files.
%
% Author:
%     Kyle Ruzic
%
% Date:
%     August 30th 2018




% general_struct - contains general information that is used
%                  for ray tracing
%     .UT                - 5x1 array containing UTC date and time - year, month,
%                          day, hour, minute
%     .speed_of_light    - speed of light
%     .re                - radius of the Earth
%     .R12               - R12 index 
%     .origin_lat        - origin latitude of rays to be
%                          traced, this should be the location
%                          of the radar. 
%     .origin_long       - origin longitude
%     .origin_ht         - origin height
%     .gain_dat          - gain pattern of radar 

general_struct.UT = [2015 5 7 8 0]; % UT - [year month day hour minute]
general_struct.speed_of_light = 2.99792458e8;
general_struct.re = 6376000; 
general_struct.R12 = 100;
general_struct.origin_lat = 52.16;
general_struct.origin_long = -106.52;
general_struct.origin_ht = 0.0;
general_struct.gain_dat = getGain('dat/SuperDARN_sas_11MHz_boresight.dat'); 


% Set up dimension information for the model
%
%     .range   - [minLat, maxLat, minLon, maxLon, minAlt, maxAlt]
%     .spacing - [numLatBins, numLonBins, numAltBins], the dimensions of
%                the model

dimensions.range = [122, 172, 24, 124, 0, 1600]; 
dimensions.spacing = [200, 400, 200];

% Generate and then save ionospheric grid, and general information
% structure

iono_struct = gen_iono_ns(general_struct.UT);
saveIonoGrid(iono_struct, general_struct)

% Generate and then save model and dimensions structure

radGrid = rayCaller_ns(dimensions, iono_struct, general_struct);
saveRadGrid(radGrid, dimensions, general_struct.UT)

% Create plots of the generated model
simplePlotter(radGrid, dimensions, UT)


