function [nudged_matrix] = nudgedEstimate(domainpoints, rangepoints)
    %Function [nudged_matrix] = nudgedEstimate(domainpoints, rangepoints)
    %
    % Returns nudged calibration matrix. Calibration matrix can be used to
    % correct coordinate-vectors by multiplying from left side.
    %
    % Based on works of Akseli Palen, please cite thesis: ADVANCED ALGORITHMS
    % FOR MANIPULATING 2D OBJECTS ON TOUCH SCREENS, 
    % https://dspace.cc.tut.fi/dpub/bitstream/handle/123456789/24173/palen.pdf
    % ?sequence=1
    
    % Alias
    D = domainpoints;
    R = rangepoints;

    % Allow arrays of different length but ignore the extra points.
    N = min(size(D,1), size(R,1));

    a1 = 0.0;
    b1 = 0.0;
    c1 = 0.0;
    d1 = 0.0;
    a2 = 0.0;
    b2 = 0.0;
    ad = 0.0;
    bc = 0.0;
    ac = 0.0;
    bd = 0.0;

    for i=1:N
        a = D(i, 1);
        b = D(i, 2);
        c = R(i, 1);
        d = R(i, 2);
        a1 = a1 + a;
        b1 = b1 + b;
        c1 = c1 + c;
        d1 = d1 + d;
        a2 = a2 + a * a;
        b2 = b2 + b * b;
        ad = ad + a * d;
        bc = bc + b * c;
        ac = ac + a * c;
        bd = bd + b * d;
    end


    % Denominator.
    % It is zero iff X[i] = X[j] for every i and j in [0, n).
    % In other words, iff all the domain points are the same.
    den = N * a2 + N * b2 - a1 * a1 - b1 * b1;

    if abs(den) < 1e-8
        % The domain points are the same.
        % We assume the translation to the mean of the range
        % to be the best guess. However if N=0, assume identity.
        if N == 0
            nudged_matrix = completeNudgedMatrix(1.0, 0.0, 0.0, 0.0);
            return;
        else
            nudged_matrix = completeNudgedMatrix(1.0, 0.0, (c1 / N) - a, (d1 / N) - b);
            return;
        end
    end
    
    % Estimators
    s = (N * (ac + bd) - a1 * c1 - b1 * d1) / den;
    r = (N * (ad - bc) + b1 * c1 - a1 * d1) / den;
    tx = (-a1 * (ac + bd) + b1 * (ad - bc) + a2 * c1 + b2 * c1) / den;
    ty = (-b1 * (ac + bd) - a1 * (ad - bc) + a2 * d1 + b2 * d1) / den;
    
    nudged_matrix = completeNudgedMatrix(s, r, tx, ty);


function nudged_matrix = completeNudgedMatrix(s, r, tx, ty)
    % Return full nudged transformation matrix
    
    nudged_matrix = [s,-r,tx;r,s,ty;0,0,1];