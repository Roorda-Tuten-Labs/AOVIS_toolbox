function arr = remove_zero_cols(in_matrix)
    % remove zero columns from an n x m input matrix

    arr = in_matrix(:, any(in_matrix, 1));

end