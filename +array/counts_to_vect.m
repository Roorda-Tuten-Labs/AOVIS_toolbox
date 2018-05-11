function vect = counts_to_vect(counts)

    vect = zeros(sum(counts), 1);
    % index of counts, i.e. the category
    % start with first category that has a non-zero count
    index = find(counts > 0, 1);
    for j = 1:sum(counts)
        if counts(index) > 0
            vect(j) = index;
        else
            index = index + 1;
        end
        if j == sum(counts(1:index)) && j ~= sum(counts) 
            index = index + 1;
            % increment index for a category with zero count to maintain
            % proper count/category relationship
            while counts(index) == 0
                index = index + 1;
            end
        end
    end    

end