function [xloc, yloc] = generate_random_walk(maxstep, startx, starty, steps)

    xloc = zeros(1, steps);
    yloc = zeros(1, steps);
    xloc(1) = startx;
    yloc(1) = starty;
    for i = 2:15
        xloc(i) = xloc(i - 1) + randi([-maxstep, maxstep], 1);
        yloc(i) = yloc(i - 1) + randi([-maxstep, maxstep], 1);
    end
    
end