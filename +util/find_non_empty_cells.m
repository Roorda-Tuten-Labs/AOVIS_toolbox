function indexes = find_non_empty_cells(cellarray, N_indexes)
    % find the index(es) of non-empty cells in an array.
    % 
    % USAGE
    % indexes = find_non_empty_cells(cellstructure, N_indexes)
    %
    % INPUT
    % cellarray     a cell array to check for non-empty cells
    % N_indexes     number of indexes to return (if they exist).
    %
    % OUTPUT
    % indexes       indexes that are not empty in the input cellarray 
    %
    if nargin < 2
        % return all indexes
        indexes = find(~cellfun('isempty', cellarray));
    else
        % if value is passed, return only first N indexes.
        indexes = find(~cellfun('isempty', cellarray), N_indexes);
    end
    
end