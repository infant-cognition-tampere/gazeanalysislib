function [diffvector] = diffVector(myvector)
    %Function [diffvector] = diffVector(myvector)
    %
    % Returns differences between consecutive elements in a vector.
    % Assumes xvector, yvector are of same length and correspond to each
    % other so that xn -> yn. The first element of the diffvector is set 0.

    diffvector = [];
    
    % if the vector is only one element long
    if length(myvector) < 2
        return
    end
    
    % calculate differences between consecutive elements
    for i=2:length(myvector)
        diffvector(i-1) = myvector(i) - myvector(i-1);
    end
    
    % put zero as first element to make vector same length
    diffvector = [0 diffvector];