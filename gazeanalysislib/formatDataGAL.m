function [DATA] = formatDataGAL(DATA)
    %function [DATA] = formatDataGAL(DATA)
    %
    % Returns empty data-struct that is of same form than the original.
    colcount = columnCount(DATA);
    for i=1:colcount
        DATA{i} = [];
    end