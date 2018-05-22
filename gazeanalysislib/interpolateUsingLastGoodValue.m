function [DATA] = interpolateUsingLastGoodValue(DATA, column, validitycolumn, accepted_validities)
    %Function [DATA] = interpolateUsingLastGoodValue(DATA, column, validitycolumn, accepted_validities)
    %
    % Interpolates values in column "column" in DATA-matrix by replacing
    % the bad value with last good value before bad values (if there is at
    % least one good value, otherwise, do nothing). Validitycolumn
    % contains the validity markings for each datapoint and good
    % validities are defined by the accepted validities-parameter. If the
    % beginning of a trail is "bad", use the first appearing good value to
    % interpolate that.

    rowcount = rowCount(DATA);
    validityvector = getColumnGAL(DATA, validitycolumn);

    % if the first value of the vector is bad, find the first non-bad.
    % take the first non-bad number and set that as first good
    good_samples = ismember(validityvector, accepted_validities);
    first_good = find(good_samples, 1, 'first');

    % check that there was at least one good value
    if isempty(first_good)
        % if not, return data as it was
        disp(' No valid data available, not changing data.');
        return;
    end

    datavector = getColumnGAL(DATA, column);
    last_non_bad = datavector(first_good);

    for i=1:rowcount
        if ~good_samples(i)
            datavector(i) = last_non_bad;
        else
            last_non_bad = datavector(i);
        end
    end

    DATA{column} = datavector;