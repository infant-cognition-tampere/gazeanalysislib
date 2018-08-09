function [hfig] = plotGazeAnimationSimple(DATA, xcol, ycol, vcol, ...
                                          timecol, accepted_validities)
    %Function [hfig] = plotGazeAnimation(DATA, xcol, ycol, vcol, timecol,
    %                                    accepted_validities)
    %
    % Function plots gaze animation. Normalized coordinates.

    delaytime = 0.01;

    xl = getColumnGAL(DATA, xcol);
    yl = getColumnGAL(DATA, ycol);

    validity_plot = ismember(getColumnGAL(DATA, vcol), ...
                             accepted_validities)./20 -0.05;
    
    rowcount = rowCount(DATA);
    starttime = getValueGAL(DATA, 1, timecol);

    % create figure
    scrsz = get(0, 'ScreenSize');
    hfig = figure('Position', [0.2*scrsz(3) 0.2*scrsz(4) scrsz(3)/2 ...
                               scrsz(4)/1.5]);
    %hfig = figure;
    set(hfig, 'name', 'gaze plot', 'numbertitle', 'off');

    % initialize the upper axes for coordinates
    a1 = subplot(2,1,1);
    h1 = plot(xl(1), yl(1), 'o');
    axis([0 1 0 1]);
    width = 0.40;
    set(a1, 'position', [(1-width)/2 0.5838 width 0.3412])
    set(a1, 'YDir', 'reverse');
    title('Gaze in the display');

    % initialize the lower axes for time-view
    a2 = subplot(2,1,2);

    x = zeros(1, rowcount);

    % construct timevector
    for i=1:rowcount
        x(i) = getValueGAL(DATA, i, timecol) - starttime;
    end

    limits = [-0.1 1.1];

    h2 = plot([0 0], [limits(1) limits(2)], 'r',  x, DATA{xcol}, ...
              x, DATA{ycol}, x, validity_plot); %'.'

    axis([min(x) max(x) limits(1) limits(2)]);

    title('Gaze coordinates');
    xlabel('Time (ms)');
    ylabel('Gaze locations (normalized)');
%    set(gcf, 'currentaxes', a1);

    for i=2:rowcount
        set(h1(1), 'Xdata', xl(1:i), 'Ydata', yl(1:i));
        set(h2(1), 'Xdata', [x(i) x(i)], 'Ydata', [limits(1) limits(2)]);

        % uncomment if drawing too slow
        if mod(i,5)==0
            drawnow;
        end

        pause(delaytime);
    end

    set(h2(1), 'Xdata', [-1 -1], 'Ydata', [limits(1) limits(2)]);