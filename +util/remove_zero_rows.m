function arr = remove_zero_rows(in_matrix)

    arr = in_matrix(any(in_matrix, 2), :);

end