function [lms] = MacBoyn2LMS(MB, LUM)

l = MB(1) * LUM;
m = (1-MB(1)) * LUM;
s = MB(2) * LUM;

lms = [l m s];

%Based off of Stockman cone spectral sensitivities and 
% luminious efficiency function.
lms = diag([0.68903, 0.348322, 0.0371597]') \ lms';

end


