function [DATA] = getRowsContainingAValue(DATA, column)
    %Function [DATA] = getRowsContainingAValue(DATA, column)
    %
    % Returns matrix DATA with rows that contain some value in specified column. 
    % Assumed that input is a cell-vector, because numerical vector is not
    % expected to have empty ''-value.

    %rowcount = rowCount(DATA);
    colcount = columnCount(DATA);
    %disp(['Getting rows that contain a value in column ' num2str(column) ' (' num2str(rowcount) ' rows in data).']);
    empty_rows = ismember(getColumnGAL(DATA, column), '');
    % remove found values from each column
    for j=1:colcount
       DATA{j}(empty_rows) = [];
    end