function [isinside] =  insideAOI(x, y, aoicoord)
    %Function [isinside] = insideAOI(x, y, aoicoord)
    %
    % Returns bool 1 if point was inside an aoi.
    % Parameters:
    %  x = decimal x-coordinate or a coordinate-vector
    %  y = decimal y-coordinate or a coordinate-vector
    %  aoicoord = [xmin xmax ymin ymax] vector that specifies aoi-limits as
    %             decimal points

    isinside = and(and(aoicoord(1) <= x, x <= aoicoord(2)), and(aoicoord(3) <= y, y <= aoicoord(4)));