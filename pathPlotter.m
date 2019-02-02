function pathVec = pathPlotter(path, dateFile, time, myFolder, radGrid, dimensions)
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
%     Produces plots of the power along the path of a given Cassiope
%     track. To produce the plots the radGrid must first be interpolated, which
%     is done by calling gridInterp which interpolates the data and then
%     returns the power for the path.
% 
% Inputs:
%     path       - the previously computed path of the Cassiope track
%     date, time - used to save and name the produced plots
%     myFolder   - the folder where all of the ionospheric/radGrid data files are
%                  stored
%     radGrid    - the model that was produced
 
    
    bottom = -60;
    top = 15;
    %for printing the images (code borrowed from https://dgleich.github.io/hq-matlab-figs/)
    width = 12;     % Width in inches
    height = 6.75;    % Height in inches
    alw = 1;    % AxesLineWidth
    fsz = 26;      % Fontsize
    lw = 1.5;      % LineWidth
    msz = 6;       % MarkerSize
                   %---------------------
    


    [pathData, pathVec] = gridInterp(path, radGrid, dimensions);
    figure(1)

    set(gcf, 'InvertHardcopy', 'off');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'Color', 'w');
    
    papersize = get(gcf, 'PaperSize');
    left = (papersize(1)- width)/2;
    bottom = (papersize(2)- height)/2;
    myfiguresize = [left, bottom, width, height];
    
    set(gcf,'PaperPosition', myfiguresize);    

    plot(epop_dat.glat(:),smooth(sqrt(epop_dat.vt1_rf_s_f(:).^2+epop_dat.vt2_rf_s_f(:).^2)),'r'); hold on    
    plot(path.lat, sqrt((pathData)*377*9)*1e3); hold off

    title(strrep('SuperDARN Saskatoon - DATE', 'DATE', dateFile))
    xlabel('Geographic Latitude, Degrees')
    ylabel('mV')    
    
    pathPowerString = strrep('pathPower_DATE-NUMUT_Xmode','DATE', ...
                           dateFile);
    pathPowerString = strrep(pathPowerString, 'NUM', num2str(time));
    Path = fullfile(myFolder, 'plots');
    Path = fullfile(Path, dateFile);
    figString = fullfile(Path, pathPowerString);

    print(figString,'-dpng','-r300') 
    
    
