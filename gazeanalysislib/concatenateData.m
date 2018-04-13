function [DATA] = concatenateData(DATA1, DATA2)
    %Function [DATA] = concatenateData(DATA1, DATA2)
    %
    % Concatenates datapoints from data2 after the last datapoint of data1. 
    % Use carefully, because the continuity of your data is in danger! 

    %rowcount1 = rowCount(DATA1);
    %rowcount2 = rowCount(DATA2);
    %disp(['Concatenating two data clips (' num2str(rowcount1) ' rows in data1, ' num2str(rowcount2) ' rows in data2).'])

    for i=1:size(DATA1, 2)
       DATA{i} = [DATA1{i}; DATA2{i}];
    end