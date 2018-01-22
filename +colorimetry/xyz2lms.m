function lms = xyz2lms(xyz)
% xyz to LMS in Smith Pokorny fundamentals

% matrix is from CVRL.org: S&P 1975 2-deg fundamentals
M = [0.15514 0.54312 -0.03286; 
    -0.15514 0.45684  0.03286;
    0        0        0.00801;];

lms = M * xyz;
