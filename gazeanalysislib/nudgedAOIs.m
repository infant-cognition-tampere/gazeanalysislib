function [nx, ny] = nudgedaois(rawx, rawy, calibmatrix)

% Performd nudged transformation for gazedata-vectors

    nx = zeros(length(rawx),1);
    ny = zeros(length(rawy),1);

    for i=1:length(rawx)
        rawgazevector=[rawx(i); rawy(i); 1];
        nudgedgaze = calibmatrix*rawgazevector;
        nx(i)=nudgedgaze(1);
        ny(i)=nudgedgaze(2);
    end