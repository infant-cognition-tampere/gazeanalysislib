function [files] = findGazeFilesInFolder(folder, regularexpression)
    %Function [files] = findGazeFilesInFolder(folder, regularexpression)
    %
    % Returns the full pathnames of files in the folder. The second 
    % parameter is regular expression that is searched in the filename
    % (e.g. '.gazedata' or '_recording1.csv')

    all_files = dir(folder);
    files = {};
    for i = 1:length(all_files)
        fname = all_files(i).name;
        if ~isempty(regexp(fname, regularexpression, 'ONCE'))
            files{end+1} = strcat(folder, filesep, fname);
        end
    end
    
    if isempty(files)
        disp('No files matching regexp in the folder.');
    end