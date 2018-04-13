function [xvector, yvector] = calculateAoiCenters(aoivector)
    %Function [xvector, yvector] = calculateAoiCenters(aoivector)
    %
    % Calculates aoi-center points for aoivector. Returns vectors of x and
    % y for the center points.

    xvector = zeros(length(aoivector),1);
    yvector = zeros(length(aoivector),1);

    for i=1:length(aoivector)
        [xvector(i), yvector(i)] = aoiCenter(str2num(aoivector{i}));
    end