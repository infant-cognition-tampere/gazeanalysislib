# gazeanalysislib
A Matlab-library for gaze analysis.

### What is gazeanalysislib?

gazeanalysislib is an open-source project created by psychology researchers and
engineers to facilitate common gaze-analysis tasks. gazeanalysislib contains
functions to load gazefiles into Matlab, to cut data, to extract various features (for example, first time in AOI, last time in AOI, time at AOI etc), and to
visualize data. The functions are not dependent on the tracker type or model. Most functions are relatively low-level, easy to understand and modify, and adaptable for different analysis requirements. The functions can be flexibly chained to build complex analysis pipelines for processing large numbers of eye tracking datafiles.

### Platforms
Matlab on any system. Octave is a free alternative, but currently we havent
tested it. Most functions work without any additional Matlab toolboxes, but
there may be exceptions.

### License
gazeanalysislib uses MIT licence.

### Reference
The project was started by researchers from Infant Cognition Lab, University of Tampere, Finland (http://uta.fi/med/icl). Please cite the following article if you publish using gazeanalysislib:

Leppänen, J.M., Forssman, L., Kaatiala, J., Yrttiaho, S.,  &  Wass, S.V. (2014). Widely applicable MATLAB routines for automated analysis of saccadic reaction times. Behavior Research Methods, 47, 538-548

## Usage
### Terminology
* gazefile = a file that contains datapoints from a recording
* HEADERS = a commonly appearing datastruct. A 1xn cell-vector that contains
  the "column"-identifiers or headers.
* DATA = a commonly appearing datastruct. A 1xn cell-vector that contains
  vectors (cell or numerical) of datapoints. The vectors inside the cell
  represent the "data-columns" in a csv-style data. Each vector is an mx1
  numerical or cell vector.
* AOI = Area Of Interest, a square-shape area that is defined by coordinates
x1,y1,x2,y2.

### Basics
The library can be downloaded from here and the extracted folder added to
Matlab-path. After that the library functions can be called and/or a script
file containing function calls can be made.

#### Example script
A short example of an analysis constructed with gazeanalysislib.
```
% Simple analysis example
% First define some parameters
ending = '.gazedata';
folder = [pwd filesep 'gazedata' filesep];
medianfilterlen = 7; % datapoints, for 60Hz
accepted_validities = [0 1];

% [xstart xend ystart yend] 0..1
my_aoi = [0.4 0.6 0.4 0.6];

% Get all the files with .gazedata extension.
files = findGazeFilesInFolder(folder, ending);

% Initialize round-counter
rc = 1;

for j = 1:length(files)

    % Load one datafile
    % The parameters given here depends on the structure of your file. How
    % many columns it has and what kind of data is in the columns.
    [DATA, HEADERS] = loadCsvAutomatic(files{j});

    % Find column numbers for this file so that we can pass these column
    % files as parameters to functions later.
    tnc = colNum(HEADERS, 'trialnumber');
    idc = colNum(HEADERS, 'id');
    timec = colNum(HEADERS,'TETTime');
    valrc = colNum(HEADERS, 'ValidityRightEye');
    vallc = colNum(HEADERS, 'ValidityLeftEye');
    xgazelc = colNum(HEADERS, 'LeftEyeNx');
    ygazelc = colNum(HEADERS, 'LeftEyeNy');
    xgazerc = colNum(HEADERS, 'RightEyeNx');
    ygazerc = colNum(HEADERS, 'RightEyeNy');

    % Replace tags e.g. if we want to group the (HEADERS-variable is unchanged)
    DATA = replaceStringsInColumn(DATA, idc, 'gcwait', 'target');
    DATA = replaceStringsInColumn(DATA, idc, 'animation', 'target');
    DATA = replaceStringsInColumn(DATA, idc, 'lateral', 'target');

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

    % Find new columns numbers for the columns that were added
    combx = colNum(HEADERS, 'CombinedX');
    comby = colNum(HEADERS, 'CombinedY');
    combval = colNum(HEADERS, 'CombinedValidity');

    % Remove data rows where there is nothin in
    DATA = getRowsContainingAValue(DATA, tnc);

    % Clip data to separate clips according to change in column "trialnumber"
    dataclips = clipDataWhenChangeInCol(DATA, tnc);

    % For each clip, do
    for i = 1:length(dataclips)
        dataclip = dataclips{i};

        % Select rows containing the desired value in a column
        dataclip = getRowsContainingValue(dataclip, idc, {'target'});

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

        % Check if the point of gaze entered the active target AOI, and
        first_time_in_aoi_row = gazeInAOIRow(dataclip, combx, comby, ...
                                             my_aoi, 'first');

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
        longest_nvc(rc) = longestNonValidSection(dataclip, combval, timec, ...
                                                 accepted_validities);
        validityc(rc) = validGazePercentage(dataclip, combval, ...
                                            accepted_validities);
        inside_aoi(rc) = gazeInAOIPercentage(dataclip, combx, comby, ...
                                             timec, my_aoi);

        % Gather information to the csv-file(s)
        [a, b, c] = fileparts(files{j});
        filename{rc} = [b c];
        trialnum{rc} = getValueGAL(dataclip, 1, tnc);

        % Simple optional visualization, comment following line if not
        % necessary, plot gazepoints and name the graph
        plotGaze2d(getColumnGAL(dataclip, combx), ...
                   getColumnGAL(dataclip, comby), ...
                   [filename{rc} ' trial: ' trialnum{rc}]);

        rc = rc + 1;
    end
end

% Generate trial-by-trial output-file
csvheaders = {'filename', 'trial_number', 'clip_duration', ...
              'first_time_in_aoi', 'validity', 'inside_aoi', ...
              'longest_nonvalid_section'};
saveCsvFile([folder 'results_tbt.csv'], csvheaders, filename, trialnum, ...
            clip_duration, first_time_in_aoi, validityc, inside_aoi, ...
            longest_nvc)
```

### Development
Program code is documented with helpstrings on functions. The overwiew can be
printed in Matlab by typing:
```
printFunctionOverview
```
Unit tests can be run with the following command. Unit tests are run to find
possible errors or dysfunctions in the code.
```
unitTests
```
See CONTRIBUTING.md for instructions and guidelines on how you can participate
on developing gazeanalysislib.

Some features may not be completed and may miss functionality or disfunction.
