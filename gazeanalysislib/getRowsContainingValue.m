function [DATA] = getRowsContainingValue(DATA, column, value)
    %Function [DATA] = getRowsContainingValue(DATA, column, value)
    %
    % Returns matrix DATA with rows that contain specified value in specified column. 
    % value can be a single value, a vector of values (numeric) or cell vector of values
    % (strings).

    colcount = columnCount(DATA);
    containing_rows = ismember(getColumnGAL(DATA, column), value);

    % remove found values from each column
    for j=1:colcount
        DATA{j}(~containing_rows) = [];
    end