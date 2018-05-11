function arr = remove_nan_rows(in_matrix)

    arr = in_matrix(~all(isnan(in_matrix), 2), :);

end