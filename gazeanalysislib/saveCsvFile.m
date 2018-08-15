function saveCsvFile(filename, headers, varargin)
    %Function saveCsvFile(filename, headers, varargin)
    %
    % Function saves data to a csv-file. Varargin must contain as many
    % columns as headers contains strings. A new function is made because 
    % Matlab's writecsv contains some problematic aspects, e.g. in
    % systems with different separator-symbol.

    % This is a variable for printing first line "sep=," so that exel and
    % other programs have easier time in loading the csv-file. Might be
    % added as parameter in future or removed.
    print_sep_headerline = 1;
    
    % check that there was parameters
    if length(varargin) < 1
        return;
    end

    rowcount = length(varargin{1});
    colcount = length(headers);

    disp(['Writing to file ' filename ': (' num2str(rowcount) ' rows, '...
          num2str(colcount) ' columns).']);

    fid = fopen(filename, 'w');

    % check that we got the file
    if fid == -1
       disp(' Could not open the file for writing.');
       return;
    end

    % print first 2 lines
    sep = ',';
    if print_sep_headerline
        fprintf(fid, 'sep=%s\n', sep);
    end
    for i=1:length(headers)
        fprintf(fid, '%s', headers{i});

        % print separator if not end-of-line
        if i ~= length(headers)
            fprintf(fid, '%s', sep);
        end
    end
    fprintf(fid,'\n');

    % print all the datavectors
    for i=1:rowcount
        for j=1:colcount
            colvector = varargin{j};
            % check that colvector contains enough values
            if i <= length(colvector)
                if iscell(colvector)
                    fprintf(fid, '%s', colvector{i});
                else
                    fprintf(fid, '%.2f', colvector(i));%num2str(colvector(i)));
                end
            end
            % print separator if not end-of-line
            if j ~= colcount
               fprintf(fid, '%s', sep); 
            end
        end
        fprintf(fid, '\n');
    end

    % close file
    fclose(fid);