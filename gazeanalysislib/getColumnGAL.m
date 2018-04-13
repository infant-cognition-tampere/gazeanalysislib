function [columnvector] = getColumnGAL(DATA, columnnumber)
    %Function [columnvector] = getColumnGAL(DATA, columnnumber)
    %
    % Returns the specified column from the DATA-matrix as a vector or
    % cell-vector according to the data type of the column.

    columnvector = DATA{columnnumber};