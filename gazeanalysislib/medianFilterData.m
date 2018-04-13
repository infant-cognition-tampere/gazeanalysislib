function [DATA] = medianFilterData(DATA, winlen, column)
    %Function [DATA] = medianFilterData(DATA, winlen, column)
    %
    % Performs median filtering to the datapoints in the specified column on
    % DATA-structure. Further information see help medianFilter.
    % Column specifies the column to filter the data with

    %disp(['Performing median filtering with window-length ' num2str(winlen) ...
    %     ' (' num2str(rowCount(DATA)) ' rows in data).']);

    DATA{column} = medianFilter(DATA{column}, winlen);