function [sampledurationsvector] = sampleDurations(sampletimesvector)
    %Function [sampledurationsvector] = sampleDurations(sampletimesvector)
    %
    % Returns a vector for sample times for each sample.

    % Format sample durations vector
    sampledurationsvector = zeros(size(sampletimesvector));

    % Loop from first to latest-1 datapoint and calculate difference time
    for i=1:length(sampletimesvector)-1
        sampledurationsvector(i) = sampletimesvector(i+1)-sampletimesvector(i);
    end
    
    % Last sample duration set to 0
    sampledurationsvector(end) = 0;
