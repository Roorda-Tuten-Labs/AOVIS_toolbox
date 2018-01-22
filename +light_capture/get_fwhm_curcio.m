function [fwhm] = get_fwhm_curcio(test_ecc, scaling, proportion)
%calculate fwhm for cone photoreceptor acceptance based on Curcio, Vis Res
%1989 and Williams et al, 1992.

%Curcio Data for Inner Segment Diameter -- Vision Research, 1989
diam=[2.17035 2.69685 3.23505 3.9429 4.14765 4.3407 4.60395 4.84965 ...
      5.1714 4.9608 5.30595 5.6277 5.7213 7.432355556 7.856514286 ...
      8.088433333 8.418866667];

diamSD=[0.161861747 0.203492567	0.14605487 0.149018791 0.199720367 ...
        0.27824252 0.361723686 0.161861747 0.297271088 0.253949601 ...
	0.283991241 0.150542021 0.256926838 0.380106272 0.135643595 ...
        0.206999688 0.348373152];

ecc=[5 45.9225 91.845 137.7675 183.69 229.6125 275.535 321.4575 ...
     367.38 413.3025 459.225 505.1475 551.07 1350 5000 8000 16000];

ecc=ecc/290; %convert to deg from microns
 
logecc=log10(ecc);

% requires curve fitting toolbox (I believe - BPS) 
if exist('fittype') > 0
    testfit=fittype('(a/(1+(1/b - 1)*exp(-c*x)))+d');
    s=fitoptions('Method','NonlinearLeastSquares',...
        'MaxFunEvals',600 ,...
        'Lower', [-Inf -Inf -Inf  0 ] ,...
        'Upper', [1 1 1 1 ]*Inf ,...
        'Startpoint',[.2 .2 .7 .5]);
    [f1,~]=fit(logecc',diam',testfit,s);

    diam_output = (feval(f1,log10(test_ecc))/290)*scaling; %in pixels
else
    diam_output = [((6.333./(1+(1./0.4057-1).*exp(-2.36.*log10(test_ecc))))+...
                    2.15).*(scaling/290)]';
end

fwhm = proportion*diam_output; %in pixels; 0.48 from Williams et al
end
