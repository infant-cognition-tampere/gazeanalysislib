function [DATA] = clipFirstRows(DATA, numrows)
    %Function [DATA] = clipFirstRows(DATA, numrows)
    %
    % Returns the first numrows rows of DATA-matrix in same format.

    rowcount = rowCount(DATA);
    colcount = columnCount(DATA);

    % if there are more rows than minimum
    if numrows < rowcount
        % put all the columns after numrows as blank
        for i=1:colcount
            rlen = length(DATA{i}); % this correction checks the number of rows for each column separately (some might have different)
            DATA{i}(numrows+1:rlen) = [];
        end
    else
        disp('  The data contains less datapoints than the firstrow-count. Not cutting anything.');
    end