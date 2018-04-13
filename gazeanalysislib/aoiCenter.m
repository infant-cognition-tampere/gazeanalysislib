function [x,y] = aoiCenter(aoi)
    %Function [x,y] = aoiCenter(aoi)
    %
    % Returns the center of the aoi in [x,y].
    x = aoi(1) + (aoi(2)-aoi(1))/2;
    y = aoi(3) + (aoi(4)-aoi(3))/2;