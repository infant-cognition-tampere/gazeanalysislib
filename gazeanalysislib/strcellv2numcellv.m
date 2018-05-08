function numcellv = strcellv2numcellv(strcellv)
    %Function numcellv = strcellv2numcellv(strcellv)
    %
    % Returns a cell vector of numbers. Cellvector because the elements of
    % the strcellv may be vectors or matrices.
    
    numcellv = {};
    for i=1:length(strcellv)
        numcellv{i} = str2num(strcellv{i});
    end