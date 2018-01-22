function [MB, lum] = LMS2MacBoyn(LMS)
%LMSTORGB Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
	LMS = [0, 0, 1]';
end

%Based off of Stockman cone spectral sensitivities and 
% luminious efficiency function.
LMS = diag([0.689903, 0.348322, 0.0371597]') * LMS;

denom = [1 1 0] * LMS;
lum = ([1 1]' * denom);
MB = LMS([1 3], :) ./ lum;

lum = lum(1, :);
end
