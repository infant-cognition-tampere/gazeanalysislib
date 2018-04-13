function [clips] = clipDataWhenChangeInCol(DATA, column)
    %Function [clips] = clipDataWhenChangeInCol(DATA, column)
    %
    % Clips DATA and returns cDATA, a clipped cell-table. DATA is being clipped
    % according to the column (number) when the value in the column is
    % different from previous row a new clip is formed. This function can
    % handle both a numerical and cellstring column values as separators.

    rowcount = rowCount(DATA);
    colcount = columnCount(DATA);

    %disp(['Clipping data (' num2str(rowcount) ' rows) when change in column ' num2str(column) '.']);

    % Format the return variable
    clips = {};
    if rowCount(DATA) == 0
       return 
    end

    % Go through rows and make a vector that swaps between 1 and 0. Swap
    % whenever there is a change in the data according to previous row's value.
    %wasdifferent = zeros(rowcount, 1);
    perioids = [];
    %marker = 0;
    values = getColumnGAL(DATA, column);
    previous_value = getValueGAL(DATA, 1, column);
    start = 1;
    for i=2:rowcount
        % compare current value to previous value
        %current_value = getValueGAL(DATA, i, column);
        current_value = values{i};
        if ~isequal(current_value, previous_value)
            %marker = mod(marker+1, 2);
            perioids = [perioids; start i-1];
            start = i;
            previous_value = current_value;
        end
%        wasdifferent(i) = marker;
    end
    
    % put the last perioid (last ending is not reached in the loop)
    perioids = [perioids;start i];

    % Find perioids for 1's and 0's. Then combine these perioids.
%    perioids = [getPerioids(find(wasdifferent==0)), getPerioids(find(wasdifferent==1))];

    % Sort these perioids according to the first column. So that clips are in
    % order.
%    sorted_perioids = sortCellOfVectorsByFirstNumber(perioids);

    % Construct data clips with values from the original matrix placed on rows
    % from the extracted perioids.
    for i=1:size(perioids, 1)
        for j=1:colcount
            tDATA{j} = DATA{j}(perioids(i,1):perioids(i, 2));
        end
        clips{end+1} = tDATA;
    end