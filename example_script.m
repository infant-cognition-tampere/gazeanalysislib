% Simple analysis example. Should be runnable by typing following command
% on Matlab on the correct folder:
% example_script

% add gazeanalysislib to Matlab path
addpath([pwd filesep 'gazeanalysislib']);

% First define some parameters
ending = '.gazedata';
folder = [pwd filesep 'example_data'];
medianfilterlen = 7; % datapoints, for 60Hz
accepted_validities = [0 1];
visualization = 1;

% make a container to predefine our AOI:s so that they are easily callable
% from dict or "hashtable"
% [xstart xend ystart yend] 0..1
aois = containers.Map;
aois('center') = [0.4 0.6 0.4 0.6];
aois('right') = [0.8 0.97 0.2 0.8];
aois('left') = [0.03 0.2 0.2 0.8];

% Get all the files with .gazedata extension.
files = findGazeFilesInFolder(folder, ending);

% Initialize round-counter
rc = 1;

for j = 1:length(files)
    % Load one datafile
    % Automatic csv-loader will try to figure out the structure of your
    % csv-file (delimiter, column type[string, float, int] etc.)
    [DATA, HEADERS] = loadCsvAutomatic(files{j});

    % Find column numbers for this file so that we can pass these column
    % files as parameters to functions later.
    tnc = colNum(HEADERS, 'trialnumber');
    idc = colNum(HEADERS, 'id');
    sidec = colNum(HEADERS, 'target');
    timec = colNum(HEADERS,'TETTime');
    valrc = colNum(HEADERS, 'ValidityRightEye');
    vallc = colNum(HEADERS, 'ValidityLeftEye');
    xgazelc = colNum(HEADERS, 'XGazePosLeftEye');
    ygazelc = colNum(HEADERS, 'YGazePosLeftEye');
    xgazerc = colNum(HEADERS, 'XGazePosRightEye');
    ygazerc = colNum(HEADERS, 'YGazePosRightEye');

    % Replace tags e.g. if we want to group the (HEADERS-variable unchanged)
    DATA = replaceStringsInColumn(DATA, idc, 'Target', 'target');

    % Combine x and y -coordinates on both eyes to one 'combined', see
    % function help for details
    [combinedx, ~] = combineEyes(DATA, xgazerc, xgazelc, valrc, vallc, ...
                                 accepted_validities);
    [combinedy, newcombined] = combineEyes(DATA, ygazerc, ygazelc, valrc, ...
                                           vallc, accepted_validities);

    % Add these new columns to data-structure, HEADERS-variable changes too
    [DATA, HEADERS] = addNewColumn(DATA, HEADERS, combinedx, 'CombinedX');
    [DATA, HEADERS] = addNewColumn(DATA, HEADERS, combinedy, 'CombinedY');
    [DATA, HEADERS] = addNewColumn(DATA, HEADERS, newcombined, ...
                                   'CombinedValidity');
    
    % We need sample durations vector in the data-structure to be able to
    % calculate some things. This vector is not there so we need to
    % generate it using sample times vector.
    sampletimesvector = getColumnGAL(DATA, timec);
    [sampledurationsvector] = sampleDurations(sampletimesvector);
    % Add this generated vector to our datastruct and headerstruct
    [DATA, HEADERS] = addNewColumn(DATA, HEADERS, sampledurationsvector, 'sampledurations');

    % Find new columns numbers for the columns that were added
    combx = colNum(HEADERS, 'CombinedX');
    comby = colNum(HEADERS, 'CombinedY');
    combval = colNum(HEADERS, 'CombinedValidity');
    durationc = colNum(HEADERS, 'sampledurations');
    
    % Remove data rows where there is nothin in
    DATA = getRowsContainingAValue(DATA, idc);

    % Clip data to separate clips when change in column "trialnumber"
    dataclips = clipDataWhenChangeInCol(DATA, tnc);

    % For each clip, do
    for i = 1:length(dataclips)
        dataclip = dataclips{i};

        % Select rows containing the desired value in a column
        dataclip = getRowsContainingValue(dataclip, idc, {'Face', 'target'});

        dataclip = clipFirstMilliSeconds(dataclip, timec, 3000);
        
        % Interpolate x and y, and apply median filter for x and y, as
        % specified in parameters
        dataclip = interpolateUsingLastGoodValue(dataclip, combx, combval, ...
                                                 accepted_validities);
        dataclip = interpolateUsingLastGoodValue(dataclip, comby, combval, ...
                                                 accepted_validities);
        dataclip = medianFilterData(dataclip, medianfilterlen, comby);
        dataclip = medianFilterData(dataclip, medianfilterlen, combx);

        % Pick a subset of data starting when target appears to the screen
        data_target = getRowsContainingValue(dataclip, idc, 'target');

        % Get target duration data
        clip_duration(rc) = getDuration(data_target, timec);
        
        % get the side of the target in this round
        side{rc} = getValueGAL(dataclip, 1, sidec);
        
        % Check if the point of gaze entered the active target AOI, and
        first_time_in_aoi_row = gazeInAOIRow(dataclip, combx, comby, ...
                                             aois(side{rc}), 'first');

        if first_time_in_aoi_row ~= -1
            % Gaze entered target AOI within the time window
            % Determnine the latency of this entry
            first_time_in_aoi(rc) = getValueGAL(dataclip, ...
                                                first_time_in_aoi_row, timec)...
                                    - getValueGAL(dataclip, 1, timec);
        else
            % If gaze did not enter the target AOI
            first_time_in_aoi(rc) = -1;
        end

        % Calculate some metrics
        longest_nvc(rc) = longestNonValidSection(dataclip, combval, durationc, ...
                                                 accepted_validities);
        validityc(rc) = validGazePercentage(dataclip, combval, ...
                                            accepted_validities);
        inside_aoi(rc) = gazeInAOIPercentage(dataclip, combx, comby, ...
                                             timec, aois(side{rc}));

        % Gather information to the csv-file(s)
        [a, b, c] = fileparts(files{j});
        filename{rc} = [b c];
        trialnum{rc} = num2str(getValueGAL(dataclip, 1, tnc));

        % visualization
        if visualization
            columns = [combx comby combval timec];
            figtitle = [filename{rc} ' trial ' trialnum{rc}];
            delaytime = 0;
            savegaze = 0;
            imageparameters = {};
            draw_aois = {aois('center'), aois(side{rc})};
            markertimes = [];
            disptext = 'This is example for 2d-plot animation';
            plotGazeAnimation(dataclip, columns, figtitle, delaytime, ...
                              accepted_validities, savegaze, ...
                              imageparameters, draw_aois, markertimes, ...
                              disptext);
        end
        rc = rc + 1;
    end
end

% Generate trial-by-trial output-file and save it to the same directory
% as example file
csvheaders = {'filename', 'trial_number', 'target_side', 'clip_duration', ...
              'first_time_in_aoi', 'validity', 'inside_aoi', ...
              'longest_nonvalid_section'};
saveCsvFile([folder filesep 'results_tbt.csv'], csvheaders, filename, ...
            trialnum, side, clip_duration, first_time_in_aoi, ...
            validityc, inside_aoi, longest_nvc)
