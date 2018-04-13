function [dist] = distanceBetweenTwoPoints(x1, y1, x2, y2)
    %Function [dist] = distanceBetweenTwoPoints(x1, x2, y1, y2)
    %
    % Function returns the distance dist between points p1, p2. NOTE: two
    % points may have different scaling (x-axis different length than y)
    % Parameters:
    %  x1 = decimal, x-coordinate of p1
    %  y1 = decimal, y-coordinate of p1
    %  x2 = decimal, x-coordinate of p2
    %  y2 = decimal, y-coordinate of p2
    
    xdiff = x1 - x2;
    ydiff = y1 - y2;
    dist = sqrt(xdiff.^2 + ydiff.^2);