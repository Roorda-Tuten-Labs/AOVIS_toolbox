function deg = mm_to_deg(rmm)
    % This function was taken from Watson (2014) and was based on an
    % older study from Drasdo & Fowler (1974).

    deg = 3.556 .* rmm + 0.05993 .* rmm.^2 - 0.007358 .* ...
          rmm.^3 + 0.0003027 .* rmm.^4;
end