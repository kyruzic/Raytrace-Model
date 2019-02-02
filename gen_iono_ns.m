function [iono_struct, general_struct] = gen_iono_ns(UT)
% Name:
%     gen_iono_ns
%
% Author:
%     Kyle Ruzic
%
% Date:
%     August 24th 2018
%
% Purpose:
%     This program is largely
%     based on the beginning of this PHaRLAP example,
%     "ray_test_3d_sp.m" The purpose of this is to generate a IRI
%     ionospheric grid, that is used by PHaRLAP to calculate the
%     path of the rays. A version of this also exists that saves
%     the generated ionosphere which allows for it to be easily
%     reloaded to prevent having to regenerate it every time you
%     make a new model for the same date and time. 
%
% Inputs:
%     UT - Vector containing date and time information, must be
%          formatted like [YYYY MM DD HH MM] 
%
% Outputs:
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






if ~exist('minute', 'var')
    minute = 0;
end

UT = UT
speed_of_light = 2.99792458e8;
re = 6376000;                               % Radius of Earth in m
R12 = 100;
origin_lat = 52.16;                         % Location of SuperDARN saskatoon
origin_long = -106.52;
origin_ht = 0.0;
doppler_flag = 1;                           

%ionospheric grid setup

ht_start = 50;          % start height for ionospheric grid (km)
ht_inc = 6;             % height increment (km)
num_ht = 301.0;           
lat_start = 30.0;      
lat_inc = 0.086;
num_lat = 701.0;
lon_start= -156.0;
lon_inc = 0.15;
num_lon = 701.0;
iono_grid_parms = [lat_start, lat_inc, num_lat, lon_start, lon_inc, num_lon, ...
      ht_start, ht_inc, num_ht];

B_ht_start = ht_start;          % start height for geomagnetic grid (km)
B_num_ht = 201; %ceil(num_ht * ht_inc/B_ht_inc); % Max that can be used is 201
B_ht_inc = (ht_inc*(num_ht-1))/(B_num_ht-1);                  % height increment (km)
B_lat_start = lat_start;
B_num_lat = 101;                % max value that can be used is 101
B_lat_inc = (lat_inc*(num_lat-1))/(B_num_lat-1);
B_lon_start = lon_start;
B_num_lon = 101;                % max value that can be used is 101
B_lon_inc = (lon_inc*(num_lon-1))/(B_num_lon-1);
geomag_grid_parms = [B_lat_start, B_lat_inc, B_num_lat, B_lon_start, ...
      B_lon_inc, B_num_lon, B_ht_start, B_ht_inc, B_num_ht];


% this block of code ensures that the size of both the iono_grid
% and geomagnetic grid are equal

kill = false; % if they aren't equal terminate the program and print
              % an error message
if (B_ht_start + (B_num_ht-1)*B_ht_inc) ~= (ht_start + (num_ht-1)*ht_inc)
    kill = true;
    fprintf("Inconsistently sized Magnetic and Ionospheric grids (height)");
    tot_B_height = (B_ht_start + (B_num_ht-1)*B_ht_inc) 
    tot_iono_height = (ht_start + (num_ht-1)*ht_inc)
elseif (B_lat_start + (B_num_lat-1)*B_lat_inc) ~= (lat_start + (num_lat-1)*lat_inc)
    kill = true;
    fprintf("Inconsistently sized Magnetic and Ionospheric grids (lat)");
    tot_B_lat = (B_lat_start + (B_num_lat-1)*B_lat_inc) 
    tot_iono_lat = (lat_start + (num_lat-1)*lat_inc)
elseif (B_lon_start + (B_num_lon-1)*B_lon_inc) ~= (lon_start + (num_lon-1)*lon_inc)
    kill = true;
    fprintf("Inconsistently sized Magnetic and Ionospheric grids (lon)");
    tot_B_lon = (B_lon_start + (B_num_lon-1)*B_lon_inc)
    tot_iono_lon = (lon_start + (num_lon-1)*lon_inc)
end

if kill
    fprintf('Size mismatch of iono and geomagnetic grids')
    return
end

%Generates the model ionosphere
tic
fprintf('Generating ionospheric and geomag grids... ')
[iono_pf_grid, iono_pf_grid_5, collision_freq, Bx, By, Bz] = ...
    gen_iono_grid_3d(UT, R12, iono_grid_parms, ...
                     geomag_grid_parms, doppler_flag, 'iri2016');
toc
fprintf('\n')

%Creates a structure with the outputs 

iono_struct.pf_grid = iono_pf_grid;
iono_struct.pf_grid_5 = iono_pf_grid_5;
iono_struct.collision_freq = collision_freq;
iono_struct.Bx = Bx;
iono_struct.By = By;
iono_struct.Bz = Bz;
iono_struct.iono_grid_parms = iono_grid_parms;
iono_struct.geomag_grid_parms = geomag_grid_parms;


