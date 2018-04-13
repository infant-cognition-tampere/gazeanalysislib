function [timein] = gazeInAOITime(DATA, xcol, ycol, durationcol, aoicoord)
    %Function [percentage] = gazeInAOITime(DATA, xcol, ycol, timecol, aoicoord)
    %
    % Returns the time when gaze is inside the area aoi.
    % aoicoord = [xmin xmax ymin ymax] specified in the x and y pixel
    % coordinates that are beign used (likely ranging from 0..1).

    % disp(['Finding time inside an aoi [' num2str(aoicoord(1)) ' ' num2str(aoicoord(2)) ' ' ...
    %       num2str(aoicoord(3)) ' ' num2str(aoicoord(4)) '] (' num2str(rowCount(DATA)) ' rows in data).']);

    % find the indices of elements inside the aoi
    inside_bools = insideAOI(DATA{xcol}, DATA{ycol}, aoicoord);
    
    % retrieve these indices from durationcolumn and sum these
    timein = sum(DATA{durationcol}(inside_bools));