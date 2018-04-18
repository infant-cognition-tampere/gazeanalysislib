function [rownumber] = gazeInAOIRow(DATA, xcol, ycol, aoicoord, type)
    %Function [rownumber] = gazeInAOIRow(data, xcol, ycol, aoicoord, type)
    %
    % Returns the rownumber when gaze is (according to last/first) inside the area aoi. 
    % If the user does not enter aoi, then -1 is returned. If user does not leave 
    % the aoi, -1 is returned.
    % GAZE = mean of two eyes, all times
    % aoicoord = [xmin xmax ymin ymax] specified in the x and y pixel
    % coordinates
    % type = 'first' returns the first row when gaze is in the aoi
    %        'last' returns the last row gaze was in the aoi
    %        'firstleave' returns the first row of gaze leaving the aoi


    x = getColumnGAL(DATA, xcol);
    y = getColumnGAL(DATA, ycol);

    switch type
        case 'first'
             rownumber = find(insideAOI(x, y, aoicoord), 1);
             if isempty(rownumber)
                 rownumber = -1;
             end
        case 'last'
            rownumber = find(insideAOI(x, y, aoicoord), 1, 'last');
            if isempty(rownumber)
                rownumber = -1;
            end
        case 'firstleave'
            rownumber = find(~insideAOI(x, y, aoicoord), 1);
            if isempty(rownumber)
                rownumber = rowCount(DATA);  
            end
    end