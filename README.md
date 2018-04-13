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
TODO
```

### Development
Program code is documented with helpstrings on functions. The overwiew can be printed in Matlab by typing:
```
printFunctionOverview
```
Some features may not be completed and may miss functionality or disfunction.