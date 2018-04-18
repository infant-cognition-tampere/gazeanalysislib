function [timein] = gazeInAOITime(DATA, xcol, ycol, durationcol, aoicoord)
    %Function [percentage] = gazeInAOITime(DATA, xcol, ycol, timecol, aoicoord)
    %
    % Returns the time when gaze is inside the area aoi.
    % aoicoord = [xmin xmax ymin ymax] specified in the x and y pixel
    % coordinates that are beign used (likely ranging from 0..1).

    % find the indices of elements inside the aoi
    inside_bools = insideAOI(DATA{xcol}, DATA{ycol}, aoicoord);
    
    % retrieve these indices from durationcolumn and sum these
    timein = sum(DATA{durationcol}(inside_bools));