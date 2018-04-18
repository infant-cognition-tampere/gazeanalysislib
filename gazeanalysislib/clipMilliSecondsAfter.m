function [DATA] = clipMilliSecondsAfter(DATA, timecol, millisec)
    %Function [DATA] = clipMilliSecondsAfter(DATA, timecol, millisec)
    %
    % Returns the millisec milliseconds after specified time of DATA-matrix in 
    % same format.

    rowcount = rowCount(DATA);
    colcount = columnCount(DATA);

    millisec_at_start = getValueGAL(DATA, 1, timecol);

    % if there are more rows than the ms limit
    if millisec_at_start + millisec < getValueGAL(DATA, rowcount, timecol)

        cutrow = find(getColumnGAL(DATA, timecol) >= millisec_at_start + millisec, 1, 'first');

        % put all the columns after numrows as blank
        for i=1:colcount
            DATA{i}(1:cutrow-1) = [];
        end
    else
        % empty all data
        DATA = formatDataGAL(DATA);
        disp('  The millisecond-limit is above timevalues found in the data. Returning empty data.');
    end