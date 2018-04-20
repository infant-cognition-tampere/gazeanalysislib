function [timein] = gazeInAOITime(DATA, xcol, ycol, durcol, aoi)
    %Function [timein] = gazeInAOITime(DATA, xcol, ycol, durcol, aoi)
    %
    % Returns the time when gaze is inside the area aoi.
    % aoicoord = [xmin xmax ymin ymax] specified in the x and y pixel
    % coordinates that are beign used (likely ranging from 0..1).
    % Wrapper for gazeInAOITimeConditional-function with all true vector.

    conditionv = ones(rowCount(DATA), 1);
    timein = gazeInAOITimeConditional(DATA, xcol, ycol, durcol, aoi, ...
                                      conditionv);