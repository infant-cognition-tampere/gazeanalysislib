function [newdatacol, newvalcol] = combineEyes(DATA, col1, col2, c1val, c2val, accepted_validities)
    %Function [newdatacol, newvalcol] = combineEyes(DATA, col1, col2, c1val, c2val, accepted_validities)
    %
    % Combines two columns to one by using the validity of columns. If both
    % columns have validity among those specified in parameter
    % accepted_validities, the mean of both columns is used as the value in
    % new column and the validity is 0. If either of the eyes has bad 
    % validity for certain datapoint and the other eye is fine,
    % the good eye is used and the validity is set to 1. If both eyes are
    % bad, -1 is used as eye value and validity value. colX, cXval-parameters 
    % are column numbers. accepted_validities is a cell array of validities
    % considered "good". newdatacol  and newvalcol are vectors formed by the
    % function containing result-coordinate and result-validity.

    rowcount = rowCount(DATA);

    badcoordinate = -1;
    badvalidity = -1;
    ok_validity_one_eye = 1;
    ok_validity_both_eyes = 0;

    % check if values in column are okay or not -> return bool vector
    validities_c1_ok = ismember(DATA{c1val}, accepted_validities);
    validities_c2_ok = ismember(DATA{c2val}, accepted_validities);

    % compare bool-vectors to construct extra-bool vectors for each
    % possible condition
    one_is_ok = and(validities_c1_ok, ~validities_c2_ok);
    two_is_ok = and(~validities_c1_ok, validities_c2_ok);
    both_ok = and(validities_c1_ok, validities_c2_ok);

    % format new vectors, value vector first full of bad value ->
    % improve on every occasion
    newdatacol = zeros(rowcount, 1) + badcoordinate;
    newvalcol = zeros(rowcount, 1) + badvalidity;

    % put okay validities if either or both (or) validities are accepted
    newvalcol(or(one_is_ok, two_is_ok)) = ok_validity_one_eye;
    newvalcol(both_ok) = ok_validity_both_eyes;
    
    % first put new values to eyes so that second one might overwrite first
    % in the occasion when both are good
    newdatacol(one_is_ok) = DATA{col1}(one_is_ok);
    newdatacol(two_is_ok) = DATA{col2}(two_is_ok);
    
    % and last overwrite those where both are good with mean-values and
    % correct the previous steps overwriting-issue
    means = mean([DATA{col1} DATA{col2}], 2);
    newdatacol(both_ok) = means(both_ok);
    