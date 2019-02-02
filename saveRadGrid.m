function saveRadGrid(radGrid, dimensions, UT)
% saves rad_grid (generated model) to a folder corresponding to its
% date, saved to "path-to-this-file/dat/date-specific-folder'
    
    date = UT;
    date(6) = 0;
    time = UT(4);
    dateFile = datestr(date, 'dd-mmmm-yyyy')
    
    myFolder = ['dat'];
    dateFolder = fullfile(myFolder, dateFile);

    
    if ~isdir(myFolder)
        [status, msg, msgID] = mkdir('dat');
        if ~status            
            msg
            return
        end
    end    
    if ~isdir(dateFolder)
        [status, msg, msgID] = mkdir(strrep('dat/dateFile', 'dateFile', dateFile));
        if ~status
            msg
            return
        end 
    end
    
    radGridString = strrep('rad-grid_DATE-NUMUT_range-test','DATE', ...
                           dateFile);
    radGridString = strrep(radGridString, 'NUM', num2str(time));
    radGridPath = fullfile(dateFolder, radGridString);
    fprintf('\n Time of model generation %f\n\n', NRT_total_time) 
    save(radGridPath, 'radGrid', '-v7.3'); 
    dimensionsPath = fullfile(dateFolder, 'dimensions.mat')
    save(dimensionsPath, '-struct', 'dimensions')