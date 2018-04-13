function [theta] = angleBetweenVectors(u, v)
    %Function [theta] = angleBetweenVectors(u, v)
    %
    % Returns angle between two vectors. Vector u is used as a reference vector
    % (zero angle). The angle is between -180..180 degrees. Parameters u,v must
    % be 2-element vectors such as [1 0].

    x1 = u(1);
    x2 = v(1);
    y1 = u(2);
    y2 = v(2);
    theta = atan2d(x1*y2-y1*x2, x1*x2+y1*y2);