function [longest_streak] = longestNonValidSection(DATA, valcol, ...
                                                   timecol, ...
                                                   accepted_validities)
    %Function [longest_streak] = longestNonValidSection(DATA, valcol, timecol, accepted_validities)
    %
    % Calculates the longest time when value in validity-column is not part of 
    % accepted_validities. The result is calculated according to the 
    % time in timecol. valcol, timecol are column numbers while
    % accepted_validities is a cell-array of validity-markings considered
    % acceptable.

    validityvector = DATA{valcol};
    timevector = DATA{timecol};

    if length(timevector) < 2
       return;
    end

    isvalidv = ismember(validityvector, accepted_validities);
    current_start = timevector(1);
    longest_streak = 0;
    for i=2:length(validityvector)

        % if current streaks continue?
        if ~isvalidv(i) % invalid data
            current = timevector(i) - current_start;
        else
            current_start = timevector(i);
            current = 0;
        end

        % if current streak surpasses longest one?
        if current > longest_streak
            longest_streak = current;
        end    
    end