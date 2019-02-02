
function radGrid = powerCalc_phase(ray, radGrid, init_ray, gain, dimensions)
% Name:
%     powerCalc_phase
%
% Author:
%     Kyle Ruzic
%
% Date:
%     August 21st 2018
%
% Purpose:
%
%     Generates ray trace model given time and date inputs, which are
%     used to load a previously generated ionosphere. The model is
%     produced by tracing ~200000 rays then binning their power which
%     is calculated according to P = (P_in * G)/(N * R^2)
%
%     Where,
%     P_in is the power of the radar
%     G is the gain pattern of the radar that is dependent on the
%     initial bearing and elevation angles of the ray
%     N is the total number of rays traced and
%     R is the distance of the point of the ray  
%
%     Phase calculations are also computed according to the
%     superposition principle, which is implemented by converting
%     the phase path of each point along the ray to a phase angle,
%     then amplitude of the point is computed by taking the cosine
%     of the phase angle times the root of the power. When the
%     model is finished computing, each bin is then squared to
%     convert the amplitude to a magnitude of power 
%
% The binning algorithm:
%     
%     for all rays
%         compute power for each point along ray (described above)
%         place power for first point in bin corresponding to ...
%             location (lat, lon, alt)
%
%         for all points along ray
%             if point in different bin than previous point
%                  place averaged power of all points within bin ...
%                      into corresponding bin
%             else 
%                  add powers
%                  track number of points in bin for averaging
%     
% Inputs:
%     ray        - structure of rays that were traced using the pharlap
%                  ray tracing algorithm, these need to be the
%                  ray_path_data output of the pharlap routine
%                  'raytrace_3d_sp'
%     radGrid   - (i*j*k) grid of power values, on first call of
%                  model generation to this function these values
%                  should all be zero 
%     init_ray   - structure containing information regarding initial
%                  conditions of the ray
%         
%         .elevs     - (1 x N) array of initial elevations for rays,
%                      where N is the number of rays traced
%         .ray_bears - (1 x N) array of initial bearing angles for
%                      rays
%         .freq      - (1 x N) array of initial frequencies of rays
%
%     gain       - a slice of the gain pattern taken at an elevation
%                  angle, this is done to lower the amount of data
%                  that needs to be held in memory, currently
%                  rayCaller handles this by using this function,
%                  powerCalc_phase, only with rays that all have the
%                  same elevation angle. Changing this will
%                  cause errors, but not prevent the program from
%                  running. So be sure not to do it without also
%                  changing how the gain is applied to the ray 
%     dimensions - A structure containing the dimensions for which the model
%                  will be produced, it should be in this form:
%                  
%                  dimensions.range = [minLat, maxLat, minLon, maxLon, minAlt, maxAlt]; 
%                  dimensions.spacing = [numLat, numLon, numAlt];
%         .range     - Contains the ranges for which the model will
%                      be generated        
%         .spacing   - more aptly named size, contains sizes of
%                      each dimension

    ranges = dimensions.range;
    ray = rangeApplier(ray, ranges);
    
    % Number of bins per degree/kilometer 
    numHeights = ranges(6) - ranges(5);    
    numLons = ranges(4) - ranges(3);
    numLats = ranges(2) - ranges(1);
    
    % Since the bin indices are integers we multiple the lat/lon/height
    % by this factor and round to place it in an integer numbered bin
    latfactor = dimensions.spacing(1)/numLats;
    lonfactor = dimensions.spacing(2)/numLons; 
    heightfactor = dimensions.spacing(3)/numHeights;    
    powerMultiplier = (750)*10.^(gain/10); % converting from dBi to linear
                                          % superDARN saskatoon has
                                          % power of 750W
    for i = 1:length(ray)
        amplitude = ...
            sqrt((powerMultiplier(floor(mod(init_ray.ray_bears(i)-(21.48),360)) ...
                                   + 1)) .* (ray(i).group_range*1e3).^(-2)); % power = 1/(4*pi*r^2)        
        
        ray(i).phase_path = ray(i).phase_path*1e3;
        phase = mod((ray(i).phase_path*(init_ray.freq(1)*1e6)*(2*pi))/(3e8),2*pi);  % computes phase given phase path
        temp = 0; % used for holding power of rays with multiple points in same bin
        counter = 0; % counts number of points in same bin

        for j = 2:length(ray(i).lat)
            % setting variables for the bins
            latBin = ceil(ray(i).lat(j-1)*latfactor); 
            lonBin = ceil(ray(i).lon(j-1)*lonfactor);
            heightBin = ceil(ray(i).height(j-1)*heightfactor);
            
            latBinNext = ceil(ray(i).lat(j)*latfactor); 
            lonBinNext = ceil(ray(i).lon(j)*lonfactor);
            heightBinNext = ceil(ray(i).height(j)*heightfactor);

            % checks if the ray is still in the same bin
            if  latBin == latBinNext && lonBin == lonBinNext && ...
                        heightBin == heightBinNext 
                if counter < 1
                    tempPhase = phase(j-1) + phase(j);
                    tempAmplitude = amplitude(j-1) + amplitude(j);
                    counter = 2;
                else
                    tempAmplitude = tempAmplitude + amplitude(j); 
                    tempPhase = tempPhase + phase(j);
                    counter = counter + 1;  % keeps track of all times it has happened
                end
                
                
            else % point of ray is in a new bin, compute the
                 % averaged power of the previous points
                
                try % tries placing value of power in bin, handles
                    % out of bounds exceptions, these should not
                    % occur, if they occur there is a problem with
                    % either how the bin is computed, or with the
                    % function rangeApplier
                    
                    if counter > 0 % more than two points of the
                                   % ray are in the same bin
                        binValue = [(tempAmplitude/counter* ...
                                     cos(tempPhase/counter)), 1];
                        % binValue is the calculated value and 1,
                        % to keep track of the number of rays that
                        % go into each bin 
                        %refer to https://www.mathworks.com/matlabcentral/answers/401079-editing-multiple-elements-of-an-array-in-one-line
                        
                        radGrid(latBin, lonBin, heightBin, 1:2) = ...
                            radGrid(latBin, lonBin, heightBin, 1:2) ... 
                            + permute(binValue(:), numel(size(radGrid)):-1:1);

                        
                        temp = 0;
                        counter = 0;                                           
                            
                    else 
                        binValue = [amplitude(j)*cos(phase(j)),1];
                       
                        radGrid(latBin, lonBin, heightBin, 1:2) = ...
                            radGrid(latBin, lonBin, heightBin, 1:2) ... 
                            + permute(binValue(:), numel(size(radGrid)):-1:1);                   
                       
                    end

                catch ex
                    % catches index out of bound error, if this
                    % error is happening repeatedly something is
                    % not working correctly 
                    if strcmp(ex.identifier,'MATLAB:badsubscript') 
                        disp('Index out of range!');                    
                    else
                        rethrow(ex)
                    end
                end
            end 
        end
    end
    
    clear ray

