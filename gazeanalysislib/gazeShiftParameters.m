function [velocityv, anglev, degchangev] = gazeShiftParameters(xvector, yvector, screen_width, screen_height, rate, angle_reference_vector, head_distance)
    %Function [velocityv, anglev, degchangev] = gazeShiftParameters(xvector, yvector, screen_width, screen_height, rate, angle_reference_vector, head_distance)
    %
    % Returns gaze-signal parameters: velocityvector, anglevector and
    % degreechangevector.
    
    % calculate difference x and y
    deltaxv = diffVector(xvector);
    deltayv = diffVector(yvector);

    % scale x so that x and y use same "units", 
    % y-range [0, 1] x could be [0, 1.6]
    % or multiply each vector accordingly with the same axis length (cm)

    xv_cm = deltaxv.*screen_width;
    yv_cm = deltayv.*screen_height;

    % calculate vectors absolute length
    absvector = sqrt(xv_cm.^2+yv_cm.^2);

    % and calculate vectors angle
    anglev = [];
    for i=1:length(xv_cm)
        %u = [1 0 0];
        v = [xv_cm(i)  yv_cm(i)];

        anglev(i) = angleBetweenVectors(angle_reference_vector, v);
    end

    % vectors speed in radians with eyes, "visual angle"
    degchangev = 2*atand((absvector./2)./head_distance);

    % turn to visual_angle/s
    sample_time = 1/rate;
    velocityv = degchangev./sample_time;