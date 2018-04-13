function [DATA] = getRowsContainingValue(DATA, column, value)
    %Function [DATA] = getRowsContainingValue(DATA, column, value)
    %
    % Returns matrix DATA with rows that contain specified value in specified column. 
    % value can be a single value, a vector of values (numeric) or cell vector of values
    % (strings).

    %rowcount = rowCount(DATA);
    colcount = columnCount(DATA);
    %disp(['Getting rows that contain specific value(s) in column ' num2str(column) ' (' num2str(rowcount) ' rows in data).']);
    containing_rows = ismember(getColumnGAL(DATA, column), value);
    % remove found values from each column
    for j=1:colcount
        DATA{j}(~containing_rows) = [];
    end