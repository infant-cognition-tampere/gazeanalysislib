# gazeanalysislib
A Matlab-library for gaze analysis.

### What is gazeanalysislib?

gazeanalysislib is an open-source project created by psychology researchers and engineers to facilitate common gaze-analysis tasks. gazeanalysislib contains functions to load gazefiles into Matlab, to cut data, extract features and visualize data  and variables in many ways. The library is designed to be used in collaboration within a script-file that processes large amounts of datafiles and is not dependend of the tracker-type or model. Functions are kept quite low-level, which gives the possibility to construct complex analyses and share the analyses easily.

### Platforms
Matlab on any system. Dependences to different Matlab-toolboxes may vary, but kept to minimum.

### License
gazeanalysislib uses MIT licence.

### Reference
The project was started by researchers from Infant Cognition Lab, University of
Tampere, Finland. Please cite us if you publish using drop.

Home page [ICL Tampere](http://uta.fi/med/icl)

## Usage
### Terminology
* gazefile = a file that contains datapoints from a recording 
* HEADERS = a commonly appearing datastruct. A 1xn cell-vector that contains the "column"-identifiers or headers.
* DATA = a commonly appearing datastruct. A 1xn cell-vector that contains vectors (cell or numerical) of datapoints. The vectors inside the cell represent the "data-columns" in a csv-style data. Each vector is an mx1 numerical or cell vector.
* AOI = Area Of Interest, a square-shape area that is defined by coordinates
x1,y1,x2,y2.

### Basics
The library can be downloaded from here and the extracted folder added to Matlab-path. After that the library functions can be called and/or a script file containing function calls can be made.

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
    [DATA, HEADERS] = loadGazedataFile(files{j}, 33, [repmat('%f ', 1, 19) '%d32 %d32 %f %f %f %f %s %s %s %s %s %d32 %f %s']);
    
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
    
    % Replace tags (HEADERS-variable is unchanged)
    DATA = replaceStringsInColumn(DATA, idc, 'gcwait', 'target');
    DATA = replaceStringsInColumn(DATA, idc, 'animation', 'target');
    
    % Combine x and y -coordinates on both eyes to one 'combined', see
    % function help for details
    [combinedx, ~] = combineEyes(DATA, xgazerc, xgazelc, valrc, vallc, accepted_validities);
    [combinedy, newcombined] = combineEyes(DATA, ygazerc, ygazelc, valrc, vallc, accepted_validities);
    
    % Add these new columns to data-structure, HEADERS-variable changes too
    [DATA, HEADERS] = addNewColumn(DATA, HEADERS, combinedx, 'CombinedX');
    [DATA, HEADERS] = addNewColumn(DATA, HEADERS, combinedy, 'CombinedY');
    [DATA, HEADERS] = addNewColumn(DATA, HEADERS, newcombined, 'CombinedValidity');
    
    % Find new columns numbers
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
        
        % Interpolate x and y, and apply median filter for x and y, as specified in parameters
        dataclip = interpolateUsingLastGoodValue(dataclip, combx, combval, accepted_validities);
        dataclip = interpolateUsingLastGoodValue(dataclip, comby, combval, accepted_validities);
        dataclip = medianFilterData(dataclip, medianfilterlen, comby);
        dataclip = medianFilterData(dataclip, medianfilterlen, combx);
        
        % Cut the data to "start" after when target appears to the screen
        % and fit the analysis window to the requirements (i.e., min and max SRTs)
        data_target = getRowsContainingValue(dataclip, idc, 'target');
        
        % Get target duration data
        clip_duration(rc) = getDuration(data_target, timec);
        
        % Check if the point of gaze entered the active target AOI, and
        first_time_in_aoi_row = gazeInAOIRow(dataclip, combx, comby, my_aoi, 'first');

        if first_time_in_aoi_row ~= -1
            % Gaze entered target AOI within the time window
            % Determnine the latency of this entry
            first_time_in_aoi(rc) = getValueGAL(dataclip, first_time_in_aoi_row, timec) - getValueGAL(dataclip, 1, timec);
        else
            % If gaze did not enter the target AOI
            first_time_in_aoi(rc) = -1;
        end
        
        % Calculate some metrics
        longest_nvc(rc) = longestNonValidSection(dataclip, combval, timec, accepted_validities);
        validityc(rc) = validGazePercentage(dataclip, combval, accepted_validities);
        inside_aoi(rc) = gazeInAOIPercentage(dataclip, combx, comby, timec, my_aoi);
        
        % Gather information to the csv-file(s)
        [a, b, c] = fileparts(files{j});
        filename{rc} = [b c];
        trialnum{rc} = getValueGAL(dataclip, 1, tnc);
        
        % Simple optional visualization, comment if not necessary
        plotGaze2d(getColumnGAL(dataclip, combx), getColumnGAL(dataclip, comby)); 
        
        rc = rc + 1;
    end
end

% Generate trial-by-trial output-file
csvheaders = {'filename', 'trial_number', 'clip_duration', 'first_time_in_aoi', 'validity', 'inside_aoi', 'longest_nonvalid_section'};
saveCsvFile([folder 'results_tbt.csv'], csvheaders, filename, trialnum, clip_duration, first_time_in_aoi, validityc, inside_aoi, longest_nvc);
```

### Development
Program code is documented with helpstrings on functions. The overwiew can be printed in Matlab by typing:
```
printFunctionOverview
```
Some features may not be completed and may miss functionality or disfunction.