function [longest_streak] = longestNonValidSection(DATA, valcol, ...
                                                   durcol, ...
                                                   accepted_validities)
    %Function [longest_streak] = longestNonValidSection(DATA, valcol, durcol, accepted_validities)
    %
    % Calculates the longest time when value in validity-column is not
    % part of accepted_validities. The result is calculated according to
    % the time in timecol. valcol, timecol are column numbers while
    % accepted_validities is a cell-array of validity-markings considered
    % acceptable.

    validityvector = DATA{valcol};
    durvector = DATA{durcol};

    isvalidv = ismember(validityvector, accepted_validities);
    current_streak = 0;
    longest_streak = 0;
    for i=1:length(validityvector)

        % if current streaks continue?
        if ~isvalidv(i) % invalid data
            current_streak = current_streak + durvector(i);
        else
            current_streak = 0;
        end

        % if current streak surpasses longest one?
        if current_streak > longest_streak
            longest_streak = current_streak;
        end    
    end