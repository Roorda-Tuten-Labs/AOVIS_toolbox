plot_chromaticity_diagram

% values obtained from color matching in the AOSLO by WT on 11/2/2015.
% Original data is in dat/Background_measurements.xslx
blue1 = [0.158, 0.15, 41.8];
blue2 = [0.159, 0.157, 34.4];
white1 = [0.228, 0.302, 42.2];
white2 = [0.229, 0.297, 50];

mean_white = mean([white1; white2], 1)

green_0power = [0.265, 0.7194, 10.2];
green_100power = [0.266, 0.7194, 3570];

% convert from xyY to XYZ
XYZ = xyYToXYZ(mean_white');

lms = xyz2lms(XYZ);

% assuming Judd-Vos/ Smith-Pokorny fundamentals
MB = LMSToMacBoyn(lms);

plot(MB(1), MB(2), 'ko');
