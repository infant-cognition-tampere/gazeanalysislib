function [files] = findSpecificGazeFilesInFolder(folder, ending, specifier_id)
%Function [files] = findSpecificGazeFilesInFolder(folder, ending, specifier_id)
%
% Returns the full pathnames of gazefiles in the folder. The gazefiles 
% ending is specified as a parameter. (e.g. '.gazedata' or '.csv')
% The third parameter is 

disp(['Retrieving the gazefiles in the folder ' folder '...']);

all_files = dir(folder);
filecounter = 0;
files = {};

for i = 1:length(all_files)
    [a, b, c] = fileparts(all_files(i).name);
    if strcmp(c, ending)
        b1 = split(b, '_');
        found = ismember(b1(2), specifier_id);
        if found == 1
            filecounter = filecounter + 1;
            files{filecounter} = [folder a b c];
        end
    end
end

if filecounter == 0
    disp('No gazefiles with provided specifier_id in the folder.');
end