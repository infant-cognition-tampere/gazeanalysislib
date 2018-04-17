function [unique_values] = uniqueColumnValues(DATA, column)
    %Function [unique_values] = uniqueColumnValues(DATA, column)
    %
    % Function returns all the values that are present in the specified column.
    % For numbers, returns a vector and for strings, returns a cell-vector.

    values = getColumnGAL(DATA, column);
    unique_values = unique(values);