function [hfig] = plotGaze2d(xg, yg, titletext)
    %Function [hfig] = plotGaze2d(xcol, ycol, titletext)
    %
    % Plots the gaze in the DATA-array 2-dimensionally. The figure handle hfig
    % is returned. xg, yg are vectors of datapoints to plot.

    hfig = figure('name', titletext);
    plot(xg, yg, '.', 'markersize', 5);
    set(gca,'YDir','reverse');
    axis([0 1 0 1]);