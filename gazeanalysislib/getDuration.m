function [dur] = getDuration(DATA, timecol)
    %Function [dur] = getDuration(DATA, timecol)
    %
    % Calculates the duration of the data-clip in the timeformat of timecol.

    if rowCount(DATA) == 0
        dur = 0;
    else
        dur = getValueGAL(DATA, rowCount(DATA), timecol) - getValueGAL(DATA, 1, timecol);
    end