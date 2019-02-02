function saveIonoGrid(iono_struct, general_struct)
    
    date = general_struct.UT;
    date(6) = 0;
    time = general_struct.UT(4);
    dateFile = datestr(date, 'dd-mmmm-yyyy');
    
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
    
    iono_string = strrep('iono_grid-TIMEUT-test.mat', 'TIME', num2str(time));
    iono_path = fullfile(dateFolder, iono_string);
    
    gen_string = strrep('gen_struct-TIMEUT-test.mat', 'TIME', num2str(time));
    gen_path = fullfile(dateFolder, gen_string);

    save(gen_path, '-struct', 'general_struct')
    save(iono_path, '-struct', 'iono_struct')  