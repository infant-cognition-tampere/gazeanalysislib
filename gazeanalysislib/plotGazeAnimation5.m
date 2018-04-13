function [hfig] = plotGazeAnimation5(DATA, columns, figtitle, delaytime, ...
                                    accepted_validities, savegaze, ...
                                    imageparameters, aois, markertimes, ...
                                    disptext, screenwidth, screenheight, trackerwidth, ...
                                    extravector, extravectorlimits, steplen, taillen)
    %Function [hfig] = plotGazeAnimation5(DATA, columns, figtitle, delaytime, ...
    %                                    accepted_validities, savegaze, ...
    %                                    imageparameters, aois, markertimes, ...
    %                                    disptext, screenwidth, screenheight, trackerwidth, ...
    %                                    extravector, extravectorlimits, steplen, taillen)
    %
    %
    % Function plots gaze animation of the participant read from the
    % DATA-matrix. figtitle specifies the name of the figure. Varargin may
    % contain still images that are placed in the animation accordingly.
    % Delaytime is to tune the loop slower if the computer is "too" fast.
    % varargin format is what follows:
    % {imagefile, coordinates, startrow, endrow}
    % coordinates are in the form [xstart xend ystart yend] ( from 0-1 sceen and 
    % with the same alignment as eyetracker, assumed top:0 bottom:1 left:0, right 1)
    % columns = [xcol ycol valcol timecol]

    % load imagefiles and do other tunings
    for i=1:length(imageparameters)
        parameters = imageparameters{i};
        img{i} = imread(parameters{1});

        % Image goes up-and down, but as here we have upside down coordinates
        % it's okay.

        % because of the structure of the loop later (begins from 2 rather
        % than 1), change the start-time 1 to 2 as it makes little difference
        % to the viewer and facilitates the loops
        if parameters{3} == 1
            parameters{3} = 2;
            imageparameters{i} = parameters;
        end
    end

    % columns to use, divide by 10 to change from mm->cm
    xg = getColumn(DATA, columns(1));
    yg = getColumn(DATA, columns(2));

    x1v = getColumn(DATA, columns(6))./10;
    y1v = getColumn(DATA, columns(7))./10;
    z1v = getColumn(DATA, columns(8))./10;

    x2v = getColumn(DATA, columns(9))./10;
    y2v = getColumn(DATA, columns(10))./10;
    z2v = getColumn(DATA, columns(11))./10;

    % make a subplot fot tags
    if length(columns) >= 5
        tagcol = columns(5);
        tags = getColumn(DATA, tagcol);
        utags = unique(tags);

     %   tagplot = zeros(length(tags), 1);
        tagplot = [];
        for i=1:length(utags)
            %tagplot = zeros(length(tags), 1);
            found_tags = strcmp(tags, utags(i));
            tagplot(i,:) = found_tags;
            %tagplot = tagplot + found_tags*i;
        end
    end

    valr = DATA{columns(3)};
    valrp = (~ismember(valr, accepted_validities) * (-1000) ) -0.01;
    rowcount = rowCount(DATA);
    starttime = getValue(DATA, 1, columns(4));

    % create figure
    scrsz = get(0,'ScreenSize');
    hfig = figure('Position', [0.2*scrsz(3) 0.05*scrsz(4) scrsz(3)*0.6 scrsz(4)*0.85]);
    set(hfig, 'name', figtitle, 'numbertitle', 'off');

    % initialize the upper axes for coordinates
    a1 = subplot(4,1,[1,2]);

    % define camera view angle
    az = 140;
    el = 12;
    tracker_angle = 20;

    p3d = Visualization3d(a1, screenheight, screenwidth, trackerwidth, tracker_angle, az, el, '3D-visualization', taillen);
    % draw aoi's to upper axis
    %for i=1:length(aois)
    %    hold on;
    %    p3d.addAoi(aois{i})
    %    hold off;
    %end

    % initialize the lower axes for time-view
    a2 = subplot(4,1,3);

    disp_text_area = uicontrol('Style', 'text', 'string', disptext, ...
                               'horizontalalignment', 'left', 'units', ...
                               'normalized', 'position', [0.05 0.01 0.90 0.03], ...
                               'fontsize', 10, 'backgroundcolor', 'white');

    x = zeros(1, rowcount);

    % construct timevector
    for i=1:rowcount
        x(i) = getValue(DATA, i, columns(4)) - starttime;
    end

    limits = [-0.1 1.1];

    %h2 = plot([0 0], [limits(1) limits(2)], 'r',  x, xg, x, yg, x, ...
    %          valrp, '.', x(markertimes), xg(markertimes), 'ko');%, 'markersize', 3);

    % draw the main plot for x,y,validity,markers,tags
    h2 = plot([0 0], [limits(1) limits(2)], 'r',  x, xg, x, yg, x, ...
              valrp, '.', x(markertimes), xg(markertimes), 'ko', x, 100*tagplot'-99, '.');%, 'markersize', 3);

    % draw legends, variable length of words for the graphs
    marks = {};
    if ~isempty(markertimes)
          marks = 'Markertimes';
    end
    l = legend(h2, [{'Timepoint', 'X','Y','Validity'} marks utags']);
    set(l, 'Position', [0.77 0.57 0.135 0.1034]); %0.135

    % draw the bottom plot for user defined things to plot
    a3 = subplot(4,1,4);
    for i=1:length(extravector)
        hold on
        h3 = plot(x, extravector{i});%, 'markersize', 3);
        hold off
    end
    axis([min(x) max(x) extravectorlimits(1) extravectorlimits(2)]);

    set(gcf, 'currentaxes', a2)
    %if length(columns) >= 5
    %    hold on
        %hk = plot(x, 0.9+0.05*tagplot', '.');
    %    hk = plot(x, 100*tagplot'-99, '.');
    %    hold off
    %    l = legend(hk, utags);
    %    set(l, 'Position', [0.77 0.52 0.135 0.1034]); %1632 1234
    %end

    axis([min(x) max(x) limits(1) limits(2)]);

    %xlabel(['Time: ' '0']);
    title('Gaze coordinates');
    xlabel('Time from start (ms)');
    ylabel('Eye coordinates (normalized)');

    set(gcf, 'currentaxes', a1);

    % if uncheck, makes the drawing significantly slower
    %legend(h2, 'Time', 'XR', 'XL', 'YR','YL', 'VR', 'VL', 'Location','NorthEastOutside');
    for i=1:steplen:rowcount

        % update timenow-vector location
        set(h2(1), 'Xdata', [x(i) x(i)], 'Ydata', [limits(1) limits(2)]);

        % 3d-drawing part
        p3d.eyeLocUpdate(1, [x1v(i) y1v(i) z1v(i)], 2.5);
        p3d.eyeLocUpdate(2, [x2v(i) y2v(i) z2v(i)], 2.5);
        p3d.gazeLocUpdate(xg(i), yg(i));

        % draw new aois from this round to 3d-view
        p3d.clearAois()
        for a=1:length(aois)
            aoi = getValue(DATA, i, aois{a});
            p3d.addAoi(str2num(aoi));
        end

        pause(delaytime);

        % save animation as gif if wanted
        if savegaze
            % Capture the plot as an image
            frame = getframe(hfig);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            % Write to the GIF File

            dtime = 0.017*4;
            if i == 1
                imwrite(imind, cm, figtitle, 'gif', 'Loopcount', inf, 'DelayTime', dtime);
            else
                imwrite(imind, cm, figtitle, 'gif', 'WriteMode', 'append', 'DelayTime', dtime);
            end
        end
    end

    set(h2(1), 'Xdata', [-1 -1], 'Ydata', [limits(1) limits(2)]);