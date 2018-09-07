classdef Visualization3d < handle
    %Class [obj] = Visualization3d(haxis, screenheight, screenwidth, trackerwidth, tracker_angle, az, el, titletxt, taillen)
    %
    % Create a 3d-view from the eyetracking setup to 'haxis'-axis.

    properties
        screenwidth
        screenheight
        rotation_matrix
        heye1
        heye2
        hgazepoint
        hgazetrail
        hgazev1
        hgazev2
        drawgazevectors = 0
        taillen
        haois = []
    end

    methods
        function [obj] = Visualization3d(haxis, screenheight, ...
                                         screenwidth,trackerwidth, ...
                                         tracker_angle, az, el, ...
                                         titletxt, taillen)
            % create rotation matrix
            % tracker angle with screen (smaller)
            obj.screenwidth = screenwidth;
            obj.screenheight = screenheight;
            obj.taillen = taillen;
            radalpha = deg2Rad(tracker_angle);
            obj.rotation_matrix = [cos(radalpha), -sin(radalpha);
                                   sin(radalpha), cos(radalpha)];
            
            % create surfaces
            NANS = [NaN NaN;NaN NaN];
            obj.heye1 = surf(haxis, NANS,NANS,NANS, 'linestyle', ...
                             'none', 'facecolor', [0.99 0.99 0.99], ...
                             'userdata', [NaN NaN NaN]);
            set(haxis, 'xdir', 'reverse');
            
            view(az, el);
            hold on
            obj.heye2 = surf(haxis, NANS,NANS,NANS, 'linestyle', ...
                             'none', 'facecolor', [0.99 0.99 0.99], ...
                             'userdata', [NaN NaN NaN]);
            % draw display object
            d = plot3([-screenwidth/2 screenwidth/2 screenwidth/2
                       0-screenwidth/2 0-screenwidth/2],...
                      [0 0 screenheight screenheight 0], ...
                      [0 0 0 0 0], 'black');
            % draw tracker with angle (the height is somewhat this 2cm)
            tcoords = obj.rotation_matrix*[0;-2];

            t = plot3([-trackerwidth/2 trackerwidth/2 trackerwidth/2 
                       0-trackerwidth/2 0-trackerwidth/2], ...
                      [tcoords(2) tcoords(2) 0 0 tcoords(2)], ...
                      [tcoords(1) tcoords(1) 0 0 tcoords(1)], 'black');

            for i=1:2
                obj.hgazetrail(i) = plot3(NaN, NaN, NaN, 'black');
                obj.hgazepoint(i) = surf(haxis, NANS,NANS,NANS, ...
                                         'linestyle', 'none', ...
                                         'facecolor', [0 0 1]);
            end
            
            % vectors from eye to gazepoint
            obj.hgazev1 = plot3(NaN, NaN, NaN, 'black');
            obj.hgazev2 = plot3(NaN, NaN, NaN, 'black');
            hold off

            % swap coordinate-axis
            obj.swapAxis(d);
            obj.swapAxis(t);
            title(titletxt);
            xlabel('x(cm)'); ylabel('z(cm)'); zlabel('y(cm)');

            % lightning stuff
            camlight
            lighting phong
            
            % limits for viewing
            axis equal
            extra = 5;
            haxis.XLim = [-screenwidth/2-extra screenwidth/2+extra];
            haxis.ZLim = [-extra screenheight+extra]; % Y
            haxis.YLim = [-1 70+extra];          % Z
        end
        
        function enableGazevectors(obj)
            obj.drawgazevectors = 1;
        end
       
        function swapAxis(obj, hgraph)

            xdata = get(hgraph, 'XData');
            ydata = get(hgraph, 'YData');
            zdata = get(hgraph, 'ZData');

            set(hgraph, 'XData', xdata);
            set(hgraph, 'YData', zdata);
            set(hgraph, 'ZData', ydata);
        end
        
        function updateSphereColor(obj, hsphere, color)

            set(hsphere, 'facecolor', color);
        end

        function updateSphereLoc(obj, hsphere, coord, d)
            
            %coord = [x y z]
            [x,y,z] = sphere;

            % apply diameter
            x = x.*d/2;
            y = y.*d/2;
            z = z.*d/2;

            set(hsphere, 'UserData', coord)
            set(hsphere, 'XData', x+coord(1));
            set(hsphere, 'YData', y+coord(2));
            set(hsphere, 'ZData', z+coord(3));

            obj.swapAxis(hsphere)
        end
        
        function eyeLocUpdate(obj, which, newcoords, r)
            % 3d-drawing part
            x = newcoords(1);
            y = newcoords(2);
            z = newcoords(3);
            
            gc = obj.rotation_matrix*[z;y];

            if which == 1
                h = obj.heye1;
            else %which ==2
                h = obj.heye2;
            end
            
            % if x-coordinate is zero -> mark eye bad (red)
            if x ==0
                obj.updateSphereColor(h, 'r')
            else
                obj.updateSphereLoc(h, [x gc(2) gc(1)], r)
                obj.updateSphereColor(h, [0.99 0.99 0.99])
            end
        end
        
        function gazeLocUpdate(obj, x, y)
            
            % Input can be one or two gazepoints. If input x is vector ->
            % consider two gazepoints given.
            
            for i=1:length(x)
                % draw second eye
                % update gazepoint2 location
                tx(i) = obj.transformX(x(i));
                ty(i) = obj.transformY(y(i));
                tcoord = [tx(i) ty(i) 0];
                obj.updateSphereLoc(obj.hgazepoint(i), tcoord, 0.8)

                % update gazetrail-line
                obj.swapAxis(obj.hgazetrail(i))
                oxdata = get(obj.hgazetrail(i), 'XDATA');
                oydata = get(obj.hgazetrail(i), 'YDATA');
                if length(oxdata) >= obj.taillen
                   oxdata(1) = [];
                   oydata(1) = [];
                end
                xdata = [oxdata tx(i)];
                ydata = [oydata ty(i)];
                zdata = zeros(size(xdata));
                set(obj.hgazetrail(i), 'XDATA', xdata);
                set(obj.hgazetrail(i), 'YDATA', ydata);
                set(obj.hgazetrail(i), 'ZDATA', zdata);
                obj.swapAxis(obj.hgazetrail(i));
            end
            
            % update gazevectors
            if obj.drawgazevectors
                % eye location
                el = get(obj.heye1, 'userdata');
                % vector from eye to gazeloc
                xdata = [el(1) tx(1)];
                ydata = [el(2) ty(1)];
                zdata = [el(3) 0];
                set(obj.hgazev1, 'XDATA', xdata);
                set(obj.hgazev1, 'YDATA', ydata);
                set(obj.hgazev1, 'ZDATA', zdata);
                obj.swapAxis(obj.hgazev1);

                % eye location
                el = get(obj.heye2, 'userdata');
                % vector from eye to gazeloc
                xdata = [el(1) tx(end)];
                ydata = [el(2) ty(end)];
                zdata = [el(3) 0];
                set(obj.hgazev2, 'XDATA', xdata);
                set(obj.hgazev2, 'YDATA', ydata);
                set(obj.hgazev2, 'ZDATA', zdata);
                obj.swapAxis(obj.hgazev2);
            end
        end
        
        function tx = transformX(obj, x)
            % transforms x-coordinate(s) from the normalized system with
            % origo on the top left of screen with dimensions [0 1] to
            % coordinate system where origo is on the middle of the tracker
            % below screen.
            tx = x.*obj.screenwidth-obj.screenwidth/2;
        end

        function ty = transformY(obj, y)
            % Same transformation as x but for y-coordinate.
            ty = (1-y).*obj.screenheight;
        end

        function addAoi(obj, aoi)
            taoi = [aoi(1) aoi(2) aoi(3) aoi(4)];
            hold on
            haoi = plot3(obj.transformX([taoi(1) taoi(1) taoi(2)
                                         taoi(2) taoi(1)]), ...
                         obj.transformY([taoi(3) taoi(4) taoi(4)
                                         taoi(3) taoi(3)]), ...
                        [0.1 0.1 0.1 0.1 0.1], 'r');
            hold off
            obj.swapAxis(haoi);
            obj.haois(end+1) = haoi;
        end
        
        function clearAois(obj)
            
            delete(obj.haois)
            obj.haois = [];
        end
    end
end