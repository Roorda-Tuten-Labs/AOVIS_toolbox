function arr = remove_nan_cols(in_matrix)

    arr = in_matrix(:, ~all(isnan(in_matrix), 1));

end