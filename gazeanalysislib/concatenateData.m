function [DATA] = concatenateData(DATA1, DATA2)
    %Function [DATA] = concatenateData(DATA1, DATA2)
    %
    % Concatenates datapoints from data2 after the last datapoint of data1. 
    % Use carefully, because the continuity of your data is in danger!

    for i=1:size(DATA1, 2)
       DATA{i} = [DATA1{i}; DATA2{i}];
    end