
maxstep = 3;
startx = 0;
starty = 0;
steps = 15;

figure; hold on;
for ii = 1:10
    
    [x, y] = util.generate_random_walk(maxstep, startx, starty, steps);

    if length(x) ~= length(y)
        error('x y lengths not equal')
    end

    if x(1) ~= startx || y(1) ~= starty
        error('start values to not match input start values')
    end

    if length(x) ~= steps || length(y) ~= steps
        error('length of location vectors does not match input steps')
    end

    if max(x) > maxstep * steps || min(y) > maxstep * steps || ...
            min(x) < maxstep * -steps || min(y) < maxstep * -steps
        error('impossible xy location')
    end

    plot(x, y, '-o')
    
end