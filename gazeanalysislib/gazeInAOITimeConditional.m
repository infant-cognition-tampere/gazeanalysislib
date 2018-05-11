function [timein] = gazeInAOITimeConditional(DATA, xcol, ycol, durcol, ...
                                             aoi, conditionvector)
    %Function [timein] = gazeInAOITimeConditional(DATA, xcol, ycol, ...
    %                                            durcol, aoi, ...
    %                                            conditionvector)
    %
    % Returns the same kind of time than gazeInAOITime(), but adds and
    % option to use conditional bool-vector on what gazepoints are included
    % in the calculation. And-operation with inside_bools and
    % conditionvector is performed.
    
    inside_bools = insideAOI(getColumnGAL(DATA, xcol), ...
                             getColumnGAL(DATA, ycol), aoi);

    % retrieve these indices from durationcolumn and sum these
    timein = sum(DATA{durcol}(and(inside_bools, conditionvector)));