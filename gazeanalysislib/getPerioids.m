function [perioids] = getPerioids(hittimes)
    %Function [perioids] = getPerioids(hittimes)
    %
    % Returns perioids of two or more consecutive indices. Perioids of
    % length one are not returned and therefore are omitted.
    
    perioids = {};
    if isempty(hittimes)
        return;
    end
    % Put an ending condition because otherwise the else-brach is never gotten
    % to. End condition is not a successor as it is one less than the last.
    hittimes(end+1) = hittimes(end) - 1;
    perioid_started = hittimes(1);
    for i=2:length(hittimes)
        if hittimes(i)-hittimes(i-1) == 1
            % was successor
        else
            % was not successor
            last_value = hittimes(i-1);
            if perioid_started ~= last_value
                perioids{end+1} = [perioid_started last_value];
            end
            perioid_started = hittimes(i);
        end
    end