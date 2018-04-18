function drawCalibrationImage(domainpointsX, domainpointsY, rangepointsX, rangepointsY)
    %Function drawCalibrationImage(domainpointsX, domainpointsY, rangepointsX, rangepointsY)
    %
    % Draws a calibration image for domain and rangepoints where the points
    % are connected to each other by a line.
    
    hfig = figure;
    plot(domainpointsX, domainpointsY, '.', rangepointsX, rangepointsY, 'ro');
    set(gca,'YDir','reverse');
    hold on
    for i=1:length(domainpointsX)
        plot([domainpointsX(i) rangepointsX(i)], [domainpointsY(i) rangepointsY(i)], 'black-');
    end
    hold off
    axis([0,1,0,1]);