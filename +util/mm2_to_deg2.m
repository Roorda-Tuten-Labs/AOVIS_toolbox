function deg2 = mm2_to_deg2(rmm, mm2)
    % deg2 = mm2_to_deg2(rmm, mm2)
    % This function was taken from Watson (2014)
    
    r = mm_to_deg(rmm);
    %rmm = 0.268 * r + 0.0003427 * r^2 - 8.3309 * 10^-6 * r^3

    % a = mm^2/deg^2 for the local area at r
    a = 0.0752 + 5.846 .* 10.^-5 .* r - 1.064 .* 10.^-5 .* r.^2 + 4.116 .* ...
        10.^-8 * r.^3;

    deg2 = mm2 .* a;

end