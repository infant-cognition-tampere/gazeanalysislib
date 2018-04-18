function [hfig] = plotGaze2d(xg, yg)
    %Function [hfig] = plotGaze2d(xcol, ycol)
    %
    % Plots the gaze in the DATA-array 2-dimensionally. The figure handle hfig
    % is returned. xg, yg are vectors of datapoints to plot.

    hfig = figure;
    plot(xg, yg, '.', 'markersize', 1);
    set(gca,'YDir','reverse');
    axis([0 1 0 1]);