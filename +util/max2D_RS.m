function [max_value, row_max, column_max] = max2D_RS(TwoD_Matrix)
    % [max_value, row_max, column_max] = max2D_RS(TwoD_Matrix)
    %
    % Written by Ram Sabesan.
    
    [n_rows, ~] = size(TwoD_Matrix);
    
    if (n_rows == 1)
        row_max = 1;      
        [max_value, column_max] = max(TwoD_Matrix);
 
    else
        [max_value_in_each_column, which_row] = max(TwoD_Matrix);
        [max_value, column_max] = max(max_value_in_each_column);
        row_max = which_row(column_max);
        
    end
end