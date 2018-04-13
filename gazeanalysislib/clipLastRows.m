function [DATA] = clipLastRows(DATA, cutrow)
    %Function [DATA] = clipLastRows(DATA, cutrow)
    %
    % Returns the last numrows rows of DATA-matrix in same format.

    rowcount = rowCount(DATA);
    colcount = columnCount(DATA);

    %disp(['Clipping rows after row ' num2str(cutrow) ' (' num2str(rowcount) ' rows in data).']);

    % if there are more rows than minimum
    if cutrow < rowcount
        % put all the columns after numrows as blank
        for i=1:colcount
            DATA{i}(1:cutrow) = [];
        end
    else
        disp('  The data contains less datapoints than the cutrow-argument. Returning empty data.');
        DATA = formatDataGAL(DATA);
    end