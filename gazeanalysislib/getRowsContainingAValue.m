function [DATA] = getRowsContainingAValue(DATA, column)
    %Function [DATA] = getRowsContainingAValue(DATA, column)
    %
    % Returns matrix DATA with rows that contain some value in specified column. 
    % Assumed that input is a cell-vector, because numerical vector is not
    % expected to have empty ''-value.

    colcount = columnCount(DATA);
    empty_rows = ismember(getColumnGAL(DATA, column), '');

    % remove found values from each column
    for j=1:colcount
       DATA{j}(empty_rows) = [];
    end