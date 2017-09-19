function [lensdata] = lenstransmission(Age, StartWavelength, EndWavelength, Res, DilatedPupil)
%spectsens returns a photopigment spectral sensitivity curve
%as defined by Carroll, McMahon, Neitz, and Neitz.
%[withOD, extinction curve] = spectsens(LambdaMax, OpticalDensity, OutputType, StartWavelength, EndWavelength,
%Resolution)




format long;

if nargin < 5, DilatedPupil = 0; end
if nargin < 4, Res = 300; end
if nargin < 3, EndWavelength = 700; end
if nargin < 2, StartWavelength = 400; end
if nargin < 1, Age = 32; end


if (StartWavelength < 400)
    lensdata = zeros(1,1);
    out = 'Cannot estimate lens yellowing below 400nm';
    disp(out);
    
end

TL1 = [ 0.6 0.51 0.433 0.377 0.327 0.295 0.267 0.233 0.207 0.187 ...
    0.167 0.147 0.133 0.12 0.107 0.093 0.08 0.067 0.053 0.04 0.033 ...
    0.027 0.02 0.013 0.007 0];
TL2 = [1 0.583 0.3 0.116 0.033 0.005 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ...
    0 0 0 0];
%TL = TL1 + TL2;
Wavelength = 400:10:650;


if (EndWavelength-StartWavelength)==0
    inc = 1/Res;
else
    inc = ((EndWavelength - StartWavelength)/Res);
end


if (Age >= 20 && Age <=60)
    % Tl = Tl1(1 + 0.02(A - 32)) + Tl2
    if (DilatedPupil == '0')
        TL = TL1 * (1 + 0.02 * (Age - 32)) + TL2; 
    else
        TL = 0.86 * ( TL1 * (1 + 0.02 * (Age - 32)) + TL2 );
    end
    
    
elseif (Age > 60)
    % Tl = TL1(1.56 + 0.0667(A - 60)) + Tl2
    if (DilatedPupil == '0')
        TL = TL1 * (1.56 + 0.0667 * (Age - 60)) + TL2;
    else
        TL = 0.86 * ( TL1 * (1.56 + 0.0667 * (Age - 60)) + TL2 );
    end
           
end

TLtrans = 1.00000 ./ (10.^TL);

lensdata = interp1(Wavelength, TLtrans, StartWavelength:inc:EndWavelength);




