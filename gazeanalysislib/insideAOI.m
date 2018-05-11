function [isinside] =  insideAOI(x, y, aoicoord)
    %Function [isinside] = insideAOI(x, y, aoicoord)
    %
    % Returns bool 1 if point was inside an aoi.
    % Parameters:
    %  x = decimal x-coordinate or a coordinate-vector
    %  y = decimal y-coordinate or a coordinate-vector
    %  aoicoord = [xmin xmax ymin ymax] vector that specifies aoi-limits
    %             as decimal points

    % function vectorization: if aoicoord-parameter was cell-array: loop
    % through cells
    if iscell(aoicoord)
        isinside = zeros(length(x),1);
        for i=1:length(aoicoord)
            isinside(i) = and(and(aoicoord{i}(1) <= x(i), ...
                                  x(i) <= aoicoord{i}(2)), ...
                              and(aoicoord{i}(3) <= y(i), ...
                                  y(i) <= aoicoord{i}(4)));
        end
    else
        isinside = and(and(aoicoord(1) <= x, x <= aoicoord(2)), ...
                       and(aoicoord(3) <= y, y <= aoicoord(4)));
    end