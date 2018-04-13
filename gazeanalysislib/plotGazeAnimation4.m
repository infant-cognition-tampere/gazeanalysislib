function [hfig] = plotGazeAnimation4(DATA, columns, figtitle, delaytime, ...
                                    accepted_validities, savegaze, ...
                                    imageparameters, aois, markertimes, ...
                                    disptext, screenwidth, screenheight, trackerwidth, ...
                                    extravector, extravectorlimits, steplen, taillen)
    %Function [hfig] = plotGazeAnimation4(DATA, columns, figtitle, delaytime, ...
    %                                    accepted_validities, savegaze, ...
    %                                    imageparameters, aois, markertimes, ...
    %                                    disptext, screenwidth, screenheight, trackerwidth, ...
    %                                    extravector, extravectorlimits, steplen, taillen)
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
    x1v = getColumn(DATA, columns(6))./10;
    y1v = getColumn(DATA, columns(7))./10;
    z1v = getColumn(DATA, columns(8))./10;

    x2v = getColumn(DATA, columns(9))./10;
    y2v = getColumn(DATA, columns(10))./10;
    z2v = getColumn(DATA, columns(11))./10;

    cx = getColumn(DATA, columns(1));
    cy = getColumn(DATA, columns(2));

    %c2x = getColumn(DATA, columns(12));
    %c2y = getColumn(DATA, columns(13));


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
    valri = ismember(valr, accepted_validities);
    valrp = (~ismember(valr, accepted_validities) * (-1000) ) -0.01;
    rowcount = rowCount(DATA);
    starttime = getValue(DATA, 1, columns(4));

    % create figure
    scrsz = get(0,'ScreenSize');
    %hfig = figure('Position', [0.2*scrsz(3) 0.2*scrsz(4) scrsz(3)/2 scrsz(4)/1.5]);
    hfig = figure('Position', [0.2*scrsz(3) 0.05*scrsz(4) scrsz(3)*0.6 scrsz(4)*0.85]);
    %hfig = figure;
    set(hfig, 'name', figtitle, 'numbertitle', 'off');

    % initialize the upper axes for coordinates
    a1 = subplot(1,3,1);

    % define camera view angle
    tracker_angle = 20;

    p3d = Visualization3d(a1, screenheight, screenwidth, trackerwidth, tracker_angle, 180, 0, 'Back', taillen);
    % draw aoi's to upper axis
     for i=1:length(aois)
        hold on;
        aoi = aois{i};
        p3d.addAoi(aoi)
        hold off;
     end

    % initialize the lower axes for time-view
    a2 = subplot(1,3,2);
    p3d2 = Visualization3d(a2, screenheight, screenwidth, trackerwidth, tracker_angle, 90, 0, 'Side', taillen);
    a3 = subplot(1,3,3);
    p3d3 = Visualization3d(a3, screenheight, screenwidth, trackerwidth, tracker_angle, 0, 90, 'Top', taillen);
    %p3d.enableGazevectors();
    %p3d2.enableGazevectors();
    %p3d3.enableGazevectors();

    disp_text_area = uicontrol('Style', 'text', 'string', disptext, ...
                               'horizontalalignment', 'left', 'units', ...
                               'normalized', 'position', [0.05 0.01 0.90 0.03], ...
                               'fontsize', 10, 'backgroundcolor', 'white');

    for i=1:steplen:rowcount

        % 3d-drawing part
        eyesize = 2.5;
        p3d.eyeLocUpdate(1, [x1v(i) y1v(i) z1v(i)], eyesize);
        p3d.eyeLocUpdate(2, [x2v(i) y2v(i) z2v(i)], eyesize);
        p3d.gazeLocUpdate([cx(i)], [cy(i)]);

        p3d2.eyeLocUpdate(1, [x1v(i) y1v(i) z1v(i)], eyesize);
        p3d2.eyeLocUpdate(2, [x2v(i) y2v(i) z2v(i)], eyesize);
        p3d2.gazeLocUpdate([cx(i)], [cy(i)]) %(cx(i), cy(i));

        p3d3.eyeLocUpdate(1, [x1v(i) y1v(i) z1v(i)], eyesize);
        p3d3.eyeLocUpdate(2, [x2v(i) y2v(i) z2v(i)], eyesize);
        p3d3.gazeLocUpdate([cx(i)], [cy(i)]);
        %p3d3.gazeLocUpdate([cx(i) c2x(i)], [cy(i) c2y(i)]);

        pause(delaytime);

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