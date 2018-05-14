function [distance_travelled] = distanceTravelled(DATA, xcol, ycol, display_width, display_height)
    %Function [distance_travelled] = distanceTravelled(DATA, xcol, ycol, display_width, display_height)
    %
    % Calculates the distance moved by eyes during the DATA-section 
    % and returns individual values for each eye. display ratio is a number
    % that describes how many times wider display is than tall. E.G for 16:10
    % display, use 1.6. display_height is the height of the display in SI unit,
    % meters. E.G. for a 51cm tall display, use 0.51.
    % EXPERIMENTAL.

    distance_travelled = 0;

    for i=2:rowCount(DATA)
        xrdist = (DATA{xcol}(i-1) - DATA{xcol}(i)) * display_width;
        yrdist = (DATA{ycol}(i-1) - DATA{ycol}(i)) * display_height;
        distance_travelled = distance_travelled + sqrt(xrdist^2+yrdist^2);
    end