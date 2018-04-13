function [gaze_violation] = AOIBorderViolationDuringNonValidSection(DATA, xcol, ycol, valcol, aoicoord, accepted_validities)
    %Function [gaze_violation] = AOIBorderViolationDuringNonValidSection(DATA, xcol, ycol, valcol, aoicoord, accepted_validities)
    %
    % Returns a truth value 1 if the gaze moves over the aoi border during
    % invalid data. Otherwise returns zero.
    % Cycle throught all the rows and after the first valid datapoint found
    % start looking if the aoi border is violated during nvs.

    %disp('Calculating if a gaze moved over aoi border during invalid data.');

    validity = DATA{valcol};
    x = DATA{xcol};
    y = DATA{ycol};

    % check that there is data and more than 2 points, so transition can happen
    if rowCount(DATA) < 2
        gaze_violation = -1;
        return
    end

    inside_bools = insideAOI(x, y, aoicoord);

    % find out are we starting from inside the area or outside
    if inside_bools(1)
        % gaze inside aoi at start
        % find first not inside
        indices = find(inside_bools == 0);
    else
        % gaze outside aoi at start
        % find first inside
        indices = find(inside_bools == 1);
    end

    % check if there is transition
    if isempty(indices)
       gaze_violation = -2;
       return
    end

    % check first point after transition and first point before transition
    if ismember(validity(indices(1)), accepted_validities) && ismember(validity(indices(1)-1), accepted_validities) 
        gaze_violation = 0;
    else
        gaze_violation = 1;
    end


%gaze_inside = -1;
%gaze_violation = 0;
%invalid_data_before = 0;
%first_valid_data_found = 0;
%rowcount = length(x);
% for i=1:rowcount
%     
%     % if both coordinates found (xm or ym not [])
%     if ismember(validity(i), accepted_validities)
%         gaze_previously = gaze_inside;
%         
%         % both coordinates inside the specific aoi
%         if insideAOI(x(i), y(i), aoicoord)
%             %(aoicoord(1) < x(i)  && x(i) < aoicoord(2)) && (aoicoord(3) < y(i) && y(i) < aoicoord(4))
%             gaze_inside = 1;
%             first_valid_data_found = 1;
%         else
%             gaze_inside = 0;
%         end
%         
%         % mark bad if the gaze in different aoi than before
%         if (gaze_previously ~= gaze_inside) && invalid_data_before
%             gaze_violation = 1;
%         end
%         
%         invalid_data_before = 0;
%         
%     else
%         if first_valid_data_found
%             % no coordinates found -> bad
%             invalid_data_before = 1;
%         end
%     end
% end