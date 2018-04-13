function [distancecolumn] = distanceBetweenTwoPointsVector(DATA, x1col, y1col, x2col, y2col, xlength, ylength)
    %function [distancecolumn] = distanceBetweenTwoPointsVector(DATA, x1col, y1col, x2col, y2col, xlength, ylength)
    %
    % Calculates distance between two points taken from vectors in the
    % DATA-datastructure. X-coordinates are multiplied with xlength and y with
    % ylength, so that usually normalized 0..1 coordinates can be corrected, if
    % the screen is not rectangular. If the axes are already having similar
    % scales, these parameters can be set to one, when the multiplication does
    % nothing.
    x1colv = DATA{x1col} * xlength;
    y1colv = DATA{y1col} * ylength;
    x2colv = DATA{x2col} * xlength;
    y2colv = DATA{y2col} * ylength;
    distancecolumn = distanceBetweenTwoPoints(x1colv, y1colv, x2colv, y2colv);