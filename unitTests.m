%% Unit test script for gazeanalysislib

% test variables
gazex =    [0.1  0.1  0.4  0.5  0.6  0.7  0.8 ];
gazey =    [0.3  0.1  0.1  0.5  0.1  0.7  0.8 ];
validity = [0    1    1    0    5    0    2   ];
times =    [2    3    4    5    6.1  7    8   ];
tag =      {'t'  't'  't'  't'  't'  'kk' 'kk'};
aoi = [0.1 0.3 0.4 0.6];
headers = {{'xgaze'}, {'ygaze'}, {'validity'}, {'tag'}, {'TETTime'}};
DATA = {gazex', gazey', validity', tag', times'};
sDATA = {gazex', gazey'};

% preconditions
accepted_validities = [0, 1];
sampledurations = [1 1 1 1.1 0.9 1 0];
vcol = colNum(headers, 'validity');
xcol = colNum(headers, 'xgaze');
ycol = colNum(headers, 'ygaze');
timecol = colNum(headers, 'TETTime');
tagcol = colNum(headers, 'tag');

%% Test 1: point inside aoi -detection
assert(insideAOI(0.1, 0.5, aoi) == 1, 'Problem with point inside aoi detection');
assert(insideAOI(0.2, 0.39, aoi) == 0, 'Problem with point outside aoi detection');

assert(isequal(insideAOI([0.5;2;0.9], [0.1;0.4;1], {[0 1 0 1], [0 1 0 1], [0 1 0 0.5]}), [1;0;0]), 'Problem with vectorized inside aoi detection');

%% Test 2: Aoi-center
[x,y] = aoiCenter(aoi);
assert(x == 0.2, 'Problem with AOI-center calculation');
assert(y == 0.5, 'Problem with AOI-center calculation');

% calculateAoiCenters()

%% Test 3: column numbers
assert(vcol == 3, 'Column number returned incorrectly.');

%% Test 4: column count
assert(columnCount(headers) == 5, 'Column count returned incorrectly.');

%% Test 5: row count
rc = rowCount(DATA);
assert(rc == 7, 'Row count returned incorrectly.');

%% Test 6: unique column values
assert(isempty(setdiff(uniqueColumnValues(DATA, tagcol), {'t', 'kk'})), 'Unique column returned incorrectly.');
assert(isempty(setdiff({'t', 'kk'}, uniqueColumnValues(DATA, tagcol))), 'Unique column returned incorrectly.');

%% Test 7: getValue
assert(getValueGAL(DATA,3,2) == gazey(3), 'getValueGAL returns incorrect value');

%% Test 8: getColumn
validityvector = getColumnGAL(DATA, vcol);
assert(isequal(validityvector, validity'), 'getColumn returns incorrect value.');

%% Test 9: Row clipping, firstrows 1..n, last rows n+1..end
cutlocation = 2;
ndata = clipFirstRows(sDATA, cutlocation);
should_be = {gazex(1:cutlocation)', gazey(1:cutlocation)'};
assert(isequal(ndata, should_be), 'First rows clipped incorrectly');
assert(isequal(clipFirstRows(sDATA, 1000), sDATA), 'Last rows clipped incorrectly: rows clipped while curtrow-parameter longer than the amount of rows.');

ndata = clipLastRows(sDATA, cutlocation);
should_be = {gazex(cutlocation+1:end)', gazey(cutlocation+1:end)'};
assert(isequal(ndata, should_be), 'Last rows clipped incorrectly');
assert(isequal(clipLastRows(sDATA, 1000), {[],[]}), 'Last rows clipped incorrectly: data nonempty while curtrow-parameter longer than the amount of rows.');

%% Test 10: concatenate data
doubledata = concatenateData(DATA, DATA);
assert(isequal(clipFirstRows(doubledata, rowCount(DATA)), DATA), 'Data concatenation problem.');
assert(isequal(clipLastRows(doubledata, rowCount(DATA)), DATA), 'Data concatenation problem.');

%% Test 11 test format data
assert(isequal(formatDataGAL(DATA), {[],[],[],[],[]}), 'Data format problem')

%% Test 12: time-specific clipping
assert(rowCount(clipFirstMilliSeconds(DATA, timecol, 0)) == 0, 'Zero-millisecods clipping returns nonzero data.');
assert(isequal(clipFirstMilliSeconds(DATA, timecol, 100000), DATA), 'Very long-millisecods clipping returns data that is not original.');
assert(rowCount(clipMilliSecondsAfter(DATA, timecol, 100000)) == 0, 'Zero-millisecods clipping returns nonzero data.');
assert(isequal(clipMilliSecondsAfter(DATA, timecol, 0), DATA), 'Very long-millisecods clipping returns data that is not original.');

assert(isequal(clipFirstMilliSeconds(DATA, timecol, 3), {gazex(1:3)', gazey(1:3)', validity(1:3)', tag(1:3)', times(1:3)'}), 'first millisecods clipping problem')
assert(isequal(clipMilliSecondsAfter(DATA, timecol, 3), {gazex(4:end)', gazey(4:end)', validity(4:end)', tag(4:end)', times(4:end)'}), 'last millisecods clipping problem')
% perhaps use clipFirstRows(DATA, 3), as this function is tested before...
% does it make test worse?

%% Test 13: difference-vector
v =     [1 2 4 5 9 -1];
diffv = [0 1 2 1 4 -10];

assert(isequal(diffVector(v), diffv), 'Problem in the difference-vector calculation');
assert(isequal(diffVector([]), []), 'Problem in the difference-vector calculation: empty');
assert(isequal(diffVector([4]), []), 'Problem in the difference-vector calculation: one-element');

%% Test 14: distance between two points
assert(distanceBetweenTwoPoints(0, 0, 0, 1) == 1, 'Problem in the distance between two-points calculation');
assert(distanceBetweenTwoPoints(0, 0, 1, 1) == sqrt(2), 'Problem in the distance between two-points calculation');
%assert(distanceBetweenTwoPointsVector(DATA, xgaze, ygaze, 

% distanceBetweentwopointsvector
% distance with itself is zerovector:
distanceBetweenTwoPointsVector(DATA, xcol, ycol, xcol, ycol, 1,1.5);
newx = getColumnGAL(DATA, xcol);
newx(4) = newx(4) + 1;
% distance with scaling (x-tested)
[DATA, headers] = addNewColumn(DATA, headers, newx, 'distancex');
assert(isequal(distanceBetweenTwoPointsVector(DATA, xcol, ycol, colNum(headers,'distancex'), ycol, 1.5,1), [0 0 0 1.5 0 0 0]'), 'problem with distance-calculation');


%% Test 15: perioids extraction
v = [-1 0 1 2 3 5 6 8 11 22 23 24 -1 26];
perioids = {[-1,3], [5,6], [22, 24]};
assert(isequal(getPerioids(v), perioids), 'perioids are not extracted properly');
assert(isequal(getPerioids([1 2 3 4]), {[1, 4]}), 'perioids are not extracted properly');
assert(isequal(getPerioids([]), {}), 'perioids are not extracted properly:nullinput');
assert(isequal(getPerioids([-2 1 3 ]), {}), 'perioids are not extracted properly:returning empty');

%% Test 16: valid gaze percentage
assert(validGazePercentage(DATA, vcol, [0,1]) == 5/rc, 'Gaze validity calculation produces incorrect values.');

%% Test 17: Sample durations
% use tolerance here, seems to somehow have some e-15 error so no isequal..
iswithintol = ismembertol(sampleDurations(times), sampledurations, 0.00000005, 'ByRows', true);
%isequal(sampleDurations(time), sampledurations)
assert(iswithintol, 'Sample durations calculation produces incorrect values.');

%% Test 18: addition of a column
colcount = length(headers);
[DATA, headers] = addNewColumn(DATA, headers, sampledurations', 'sampledurations');
durcol = colNum(headers, 'sampledurations');
assert(length(DATA{1}) == rc, 'Adding a new colum produces incorrect number of rows.');
assert(length(headers) == colcount+1, 'Adding a new colum produces incorrect number of columns.');
assert(getValueGAL(DATA, 1, durcol) == sampledurations(1), 'The new header and datavector are not matching each other.');

%% Test 19: gaze in AOI percentage
aoicoord = [0.5 1 0.5 1];
inside_time = 1.1 + 1; % + 1;
recording_length = sum(sampleDurations(times));
should_be = inside_time/recording_length;
gazecount = gazeInAOIPercentage(DATA, xcol, ycol, durcol, aoicoord);
assert(gazecount == should_be, 'Gaze in AOI percentage produces incorrect values.');
assert(gazeInAOIPercentage(clipFirstRows(DATA, 1), xcol, ycol, durcol, aoicoord) == 0, 'Gaze in AOI does not seem to work for one value.');
assert(gazeInAOIPercentage(clipFirstRows(DATA, 1), xcol, ycol, durcol, [0 1 0 1]) == 1, 'Gaze in AOI does not seem to work for one value.');
%assert(gazeInAOIPercentage(clipLastRows(DATA, rc-1), xcol, ycol, durcol, aoicoord) == 1, 'Gaze in AOI does not seem to work for one value.');

%% Test 20: median filter
v = [1 2 1 3 5 1 2 3];
v_correct = [1 1 2 3 3 2 2 3];
v_filtered = medianFilter(v, 3);
assert(isequal(v_correct, v_filtered), 'Median filter is not producing correct values with test vector.');

%% Test 21: medianfilterdata


%% Test 22: data duration
assert(getDuration(DATA, timecol) == times(end)-times(1), 'Data duration is not calculated correctly');

%% Test 23: aoi border violation

%gazex =    [0.1  0.1  0.4  0.5  0.6  0.7  0.8 ];
%gazey =    [0.3  0.1  0.1  0.5  0.1  0.7  0.8 ];
%validity = [0    1    1    0    5    0    2   ];
assert(AOIBorderViolationDuringNonValidSection(DATA, xcol, ycol, vcol, [0.55 0.8, 0.1, 0.7], [0,1]) == 1, 'Border violation should be.');
assert(AOIBorderViolationDuringNonValidSection(DATA, xcol, ycol, vcol, [0.3 0.4 0 1], [0,1,2]) == 0, 'Border violation should not be.');
assert(AOIBorderViolationDuringNonValidSection(DATA, xcol, ycol, vcol, [0.05 0.6, 0, 1], [0,1]) == 1, 'Border violation should be.');
assert(AOIBorderViolationDuringNonValidSection(DATA, xcol, ycol, vcol, [0.05 0.6, 0, 1], [0,1,5]) == 0, 'Border violation should not be.');

%% Test 24: angle between vectors
assert(angleBetweenVectors([1 1], [1 1]) == 0)
assert(angleBetweenVectors([1 1], [0 1]) == 45)
assert(angleBetweenVectors([-1 0], [0 1]) == -90)
assert(angleBetweenVectors([0 1], [-1 -1]) == 135)

%% Test 25: clip data when value changes in column
clipdata = clipDataWhenChangeInCol(DATA, tagcol);
assert(rowCount(DATA) == rowCount(clipdata{1}) + rowCount(clipdata{2}), 'Data clips combined do not have the same sum of rows than the original data');
assert(isequal(DATA, concatenateData(clipdata{1}, clipdata{2})), 'Data clips concatenated are not identical to original data');

%% Test 26: deg2rad
assert(deg2rad(0) == 0, 'Angle 0 is not calculated correctly.');
assert(deg2rad(90) == pi/2, 'Angle 90 is not calculated correctly.');
assert(deg2rad(180) == pi, 'Angle 180 is not calculated correctly.');
assert(deg2rad(360) == 2*pi, 'Angle 360 is not calculated correctly.');
assert(deg2rad(450) == 2.5*pi, 'Angle 450 is not calculated correctly.');

%% Test 27: unique column values
assert(isequal(uniqueColumnValues(DATA, tagcol), {'kk'; 't'}), 'Unique column values is not working correctly');

%% test 28: gazepoint duration column addition


%% Test 29: gaze in aoi time
time1 = gazeInAOITime(DATA, xcol, ycol, durcol, [0.5 1 0 1]);
time2 = gazeInAOITime(DATA, xcol, ycol, durcol, [0 0.49 0 1]);

iswithintol1 = ismembertol(time1, 3, 0.00000005, 'ByRows', true);
assert(iswithintol1, 'Time that gaze is inside AOI is not returned correctly.');
iswithintol1 = ismembertol(time2, 3, 0.00000005, 'ByRows', true);
assert(iswithintol1, 'Time that gaze is inside AOI is not returned correctly.');
% these combined should be the duration of the data
assert(recording_length == time1 + time2, 'Time in aoi: time summed over multiple aois covering all screen seems to not provide the whole duration of the experiment.')

time3 = gazeInAOITimeConditional(DATA, xcol, ycol, durcol, [0 0.49 0 1], [0,0,1,1,1,0,0]'); %2/7
time4 = gazeInAOITimeConditional(DATA, xcol, ycol, durcol, [0 0.49 0 1], [0,0,0,0,1,0,0]'); %0
assert(time3 == 1, 'Time that gaze is inside AOI CONDITIONAL is not returned correctly.');
assert(time4 == 0, 'Time that gaze is inside AOI CONDITIONAL is not returned correctly.');
%% Test 30: combineEyes
% 2-> here bad
% 5-> here good 
% 3-> good but doubled to 0.8
% last -> both are incorrect

gazex2 =    [0.1  5.1  0.8  0.5  -0.6  0.7  0.8 ];
validity2 = [0    3    1    0    0     0    2   ];
should_be = [0.1  0.1  0.6  0.5  -0.6  0.7  -1];

[DATA, headers] = addNewColumn(DATA, headers, gazex2', 'x2gaze');
[DATA, headers] = addNewColumn(DATA, headers, validity2', 'validity2');
combined_eyes = combineEyes(DATA, colNum(headers, 'x2gaze'), xcol, colNum(headers, 'validity2'), vcol, accepted_validities);

isin = min(ismembertol(should_be', combined_eyes, 0.000005));
assert(isin, 'Eye-combination is not working correctly.');

%% Test 31: getrowscontainingAvalue
[d, h] = addNewColumn(DATA, headers, {'', '','a', '', 'a', 'a', '123'}', 'emptytestcolumn');
cet = colNum(h, 'emptytestcolumn');
% additional test to clipDataWhenChangeInCol
h = clipDataWhenChangeInCol(d, cet);
isequal(h{4}{cet}, {'a'; 'a'}, 'There seems to be a problem with one-length elements when detecting change in a column.');

%% Test 32: strcellv2numcellv
numcellv = strcellv2numcellv({'[1 2 3 4]'; '[0 0 0 -1]'});
assert(isequal(numcellv, {[1 2 3 4]; [0 0 0 -1]}), 'String-valued cellvector is not changed to numeric cellvector correctly');

%% Test 33: getrowscontainingvalue
rows = {{''; 'a'; ''; 'a'; 'test'}, [1;2;3;4;5]};
data_with_something = getRowsContainingAValue(rows, 1);
assert(isequal(getColumnGAL(data_with_something, 2), [2;4;5]), 'getrowscontainingavalue error');

%% Test 34: removerowscontainingvalue
data_with_values_removed = removeRowsContainingValue(rows, 1, 'a');
assert(isequal(getColumnGAL(data_with_values_removed, 2), [1;3;5]), 'removerows error');

%% Test 35: testdataconsistency
rows_nonconsistent = {{'a'; 'b'}, [1]};
assert(testDataConsistency(rows_nonconsistent) == 0, 'nonconsistent data detected incorrectly');
assert(testDataConsistency(rows) == 1, 'consistent data detected incorrectly');

%% Test 36: replacestringsincolumn
rows_replaced = replaceStringsInColumn(rows, 1, 'a', 'test');
assert(isequal(getColumnGAL(rows_replaced, 1), {''; 'test'; ''; 'test'; 'test'}));

%% Test 37: gazeinaoirow
first = gazeInAOIRow(DATA, xcol, ycol, [0.05 0.15 0.05 0.15], 'first');
last = gazeInAOIRow(DATA, xcol, ycol, [0.35 0.45 0.05 0.15], 'last');
assert(first == 2, 'gaze enter aoi "first" not found correctly');
assert(last == 3, 'gaze enter aoi "last" not found correctly');

%% Test 38: distanceTravelled
% make a simple triangle that the gaze travels 
rows3 = {[1 2 2 1], [1 1 2 1]};
d = 20 + 10 + sqrt(10^2+20^2);
dist = distanceTravelled(rows3, 1, 2, 20, 10);
assert(dist == d, 'distanceTravelled error');

%% Test 39: longestnonvalidsection
% should detect the 1 + 1.1 second streak in the middle
rows4 = {[1 2 1 1.1 1 4 1], [1 0 1 0 0 1 0]};
longest_nvs = longestNonValidSection(rows4, 2, 1, [1]);
assert(longest_nvs == 2.1, 'longest nonvalidsection not working correctly');

%% Test 40: interpolation
%% Test 41: nudgedestimate
%% gazeshiftparameters