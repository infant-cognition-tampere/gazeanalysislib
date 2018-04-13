function [percentage] = gazeInAOIPercentage(DATA, xcol, ycol, durationcol, aoicoord)
    %Function [percentage] = gazeInAOIPercentage(DATA, xcol, ycol, durcol, aoicoord)
    %
    % Returns the percentage of time when gaze is inside the area aoi. If the
    % user does not enter aoi, then -1 is returned. Gaze 
    % aoicoord = [xmin xmax ymin ymax] specified in the x and y pixel
    % coordinates that are beign used (likely ranging from 0..1). Durcol is the
    % datapoint duration column.

    rowcount = rowCount(DATA);

    % disp(['Finding percentage of gaze inside an aoi [' num2str(aoicoord(1)) ' ' num2str(aoicoord(2)) ' ' ...
    %       num2str(aoicoord(3)) ' ' num2str(aoicoord(4)) '] (' num2str(rowcount) ' rows in data).']);

    % Find the indices of elements inside the aoi
    inside_bools = insideAOI(DATA{xcol}, DATA{ycol}, aoicoord);
    
    % Retrieve these indices from durationcolumn and sum these, avoid
    % division by zero.
    percentage = -1;
    
    if rowcount > 0
        percentage = double(sum(DATA{durationcol}(inside_bools)))/double(sum(DATA{durationcol}));
    end