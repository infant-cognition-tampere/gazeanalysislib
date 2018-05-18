function [DATA, HEADERS, fileformat, delimcount] = loadCsvAutomatic(file)
    %Function [DATA, HEADERS, fileformat, delimcount] = loadCsvAutomatic(file)
    %
    % Loads the gaze file and returns all datalines and columns in
    % DATA-array and headers in HEADERS-cell-vector. Normal load function
    % is sensitive in content format but this function goes through a
    % normal thought-process of reasoning what's in a file, what is the
    % delimiter, how many columns and what type of data is in the column.
    % This function might make a false guess about the file structure. If
    % this is the case use format-spesific load function.

    disp(['Reading file ' file]);
    str = fileread(file);

    % corrections to the unwanted marks on the file (some usual found in
    % gazedata files)
    if contains(str, '1.#')
        str = strrep(str, '-1.#INF',  '-1');
        str = strrep(str, '-1.#IND',  '-1');
        str = strrep(str, '1.#INF',   '-1');
        str = strrep(str, '1.#IND',   '-1');
        str = strrep(str, '1.#QNAN',  '-1');
        str = strrep(str, '-1.#QNAN', '-1');
    end

    % exctract only the header line
    a = textscan(str, '%s', 1, 'delimiter', '\n');
    headerstr = a{1}{1};
    
    % analyze the header line and try to figure out delimiter
    ctab = count(headerstr, sprintf('\t'));
    ccomma = count(headerstr, ',');
    csemicolon = count(headerstr, ';');
    cspace = count(headerstr, ' ');
    
    [delimcount, ind] = max([ctab ccomma csemicolon cspace]);
    
    if ind == 1
        delimiter = sprintf('\t');
    elseif ind == 2
        delimiter = ',';
    elseif ind == 3
        delimiter = ';';
    else
        delimiter = ' ';
    end

    % form header format string
    headerformat = ['%s' repmat('%s', 1, delimcount)];

    % read header lines
    HEADERS = textscan(str, headerformat, 1, 'delimiter', delimiter);

    % analyze first dataline
    a = textscan(str, headerformat, 1, 'HeaderLines', 1, 'delimiter', ...
                 delimiter);

    fileformat = '';
    for i = 1:length(a)
        value = a{i}{1};
        
        if isempty(str2num(value)) || length(str2num(value)) > 1
            % string (if there is a char or is empty->not number, if length
            % is longer than 1, there is a table which need to be processed
            % from str later on)
            fileformat = strcat(fileformat, '%s');
        else
            if count(value, '.') == 0
                % int (does not contain point in the string)
                fileformat = strcat(fileformat, '%d32');
            else
                % float
                fileformat = strcat(fileformat, '%f');
            end                
        end
    end
   
    % read data columns
    DATA = textscan(str, fileformat, 'HeaderLines', 1, 'Delimiter', ...
                    delimiter);