function [PSF] = GeneratePSF(ap_field, psf_pupil, zernike_pupil, field_size, lamda, diff_limited, defocus)
%UNTITLED2 Generates PSF for a given field size, pupil size, and test
%wavelength
%   ap_field is the field size, in pixels; typically 512;
%   psf_pupil is the pupil size for testing;
%   zernike_pupil is the pupil size for the wavefront testing (usually == psf_pupil)
%   field_size is the field size, in ARCMIN; (60 arcmin per degree, so 72 for a 1.2deg field)
%   lamda is the stimulus wavelength;
%   diff_limited: if diff_limited == 1, set all Zernike coefficients to
%   zero; else, input a given .zer from HSWS

global PARAMS;	%set as global so that PARAMS(6) can be changed in a subroutine

PARAMS(1) = ap_field; 	% size of pupil aperture field in pixels (this defines the resolution of the calculation)
PARAMS(5) = lamda;	% imaging wavelength in microns
PARAMS(6) = 0;		% number of pixels over which PSF is calculated (do not adjust here set in Zernikephase subroutine)
PARAMS(7) = 20; % increase to enhance the display of the wavefront (doesn't affect calculation)

if diff_limited == 1;
    % Zernike coeffs
    % Preset all coefficients to 0 and edit each value as desired
    
    % tilt
    c(1)=0; 	c(2)=0.0;
    %defocus and astigmatism
    c(3)=0; 	c(4)=0;	c(5)=0;
    %coma like
    c(6)=0.0;	c(7)=0.00;	c(8)=0;	c(9)=0.0;
    %spherical aberration like
    c(10)=0;	c(11)=0.0;	c(12)=00;	c(13)=0;	c(14)=0;
    %higher order (each row is a new radial order)
    c(15)=0;	c(16)=0;	c(17)=0;	c(18)=0;	c(19)=0;	c(20)=0;
    c(21)=0;	c(22)=0;	c(23)=0;	c(24)=0;	c(25)=0;	c(26)=0;	c(27)=0;
    c(28)=0;	c(29)=0;	c(30)=0;	c(31)=0;	c(32)=0;	c(33)=0;	c(34)=0;	c(35)=0;
    c(36)=0;	c(37)=0;	c(38)=0;	c(39)=0;	c(40)=0;	c(41)=0;	c(42)=0;	c(43)=0;	c(44)=0;
    c(45)=0;	c(46)=0;	c(47)=0;	c(48)=0;	c(49)=0;	c(50)=0;	c(51)=0;	c(52)=0;	c(53)=0;	c(54)=0;
    c(55)=0;	c(56)=0;	c(57)=0;	c(58)=0;	c(59)=0;	c(60)=0;	c(61)=0;	c(62)=0;	c(63)=0;	c(64)=0;	c(65)=0;
    
    PARAMS(2) = psf_pupil;   % size of pupil in mm for which PSF and MTF is to be calculated
    PARAMS(3) = zernike_pupil;	% size of pupil in mm that Zernike coefficients define. NOTE: You can define the aberrations
    % for any pupil size and calculate their effects for any smaller aperture.
    PARAMS(4) = 60*PARAMS(1)*(180/3.1416)*PARAMS(5)*.001/field_size;
    param4orig = PARAMS(4); 	% size of pupil field in mm (use a large field to magnify the PSF)
    
elseif diff_limited == 0;
    [fname,pname] = uigetfile('*.zer','Open Coefficient File');
    fid = fopen([pname fname],'r');
    version = fgetl(fid);% fscanf(fid,'%s',1);
    instrument = fgetl(fid);% fscanf(fid,'%s',1);
    manuf = fgetl(fid);% fscanf(fid,'%s',1);
    oper = fgetl(fid);% fscanf(fid,'%s',1);
    pupoff = fgetl(fid);% fscanf(fid,'%s',1);
    geooff = fgetl(fid);% fscanf(fid,'%s',1);
    datatype = fgetl(fid);% fscanf(fid,'%s',1);
    Rfit = fscanf(fid,'%s %f\n',[1 2]);% fscanf(fid,'%s',1);
    Rfit=Rfit(length(Rfit));
    Rmax = fgetl(fid);% fscanf(fid,'%s',1);
    waverms = fgetl(fid);% fscanf(fid,'%s',1);
    order = fgetl(fid);% fscanf(fid,'%s',1);
    strehl = fgetl(fid);% fscanf(fid,'%s',1);
    refent = fgetl(fid);% fscanf(fid,'%s',1);
    refcor = fgetl(fid);% fscanf(fid,'%s',1);
    resspec = fgetl(fid);% fscanf(fid,'%s',1);
    data = fgetl(fid);% fscanf(fid,'%s',1);
    c = fscanf(fid,'%i %i %g',[3 inf]); %read the first line
    fclose(fid);
    c=c(3,2:66); %ignore the piston term (check this carefully!!!!!)
    
    %     %set these parameter based on what is contained in the *.zer file
    %     PARAMS(2)=2*Rfit; %default setting is the pupil size that the Zernike coeffs define, PARAMS(3)
    %     PARAMS(3)=2*Rfit;
    %     PARAMS(4)=15; param4orig = PARAMS(4); %automatically compute the field size
    PARAMS(2) = psf_pupil;   % size of pupil in mm for which PSF and MTF is to be calculated
    PARAMS(3) = zernike_pupil;	% size of pupil in mm that Zernike coefficients define. NOTE: You can define the aberrations
    % for any pupil size and calculate their effects for any smaller aperture.
    PARAMS(4) = 60*PARAMS(1)*(180/3.1416)*PARAMS(5)*.001/field_size;
    param4orig = PARAMS(4); 	% size of pupil field in mm (use a large field to magnify the PSF)
    
else
    %do nothing
end

if (PARAMS(2) < PARAMS(3))
    c = light_capture.TransformC(c,PARAMS(3),PARAMS(2),0,0,0);
    c(1:5) = 0; %set tilt, defocus and astigmatism to zero
    PARAMS(3) = PARAMS(2); %set PARAMS(3) to correspond to the new coefficients.
end

    DefocusInDiopters = defocus;

    PARAMS(2)=psf_pupil;
    
    if (PARAMS(2) < PARAMS(3))
        c = light_capture.TransformC(c,PARAMS(3),PARAMS(2),0,0,0);
        c(1:5) = 0; %set tilt, defocus and astigmatism to zero    
        PARAMS(3) = PARAMS(2); %set PARAMS(3) to correspond to the new coefficients. 
    end
    
    c(4)=(1e6/(4*sqrt(3)))*DefocusInDiopters*((PARAMS(2)/2000)^2); % convert DefocusInDiopters into a Zernike coefficient

    % calculate the RMS
    rms=sqrt(sum(c(1:65).^2));

    % print the result to the screen
%     fprintf('%g\t%g\t',DefocusInDiopters, rms);

%Generate PSF using compPSFOSA.m
    PARAMS(4) = param4orig; %reset PARAMS(4) to its original value just in case it was changed in another script
    [PSF] = light_capture.compPSFOSA(c); % call the script compPSFOSA.m to generate PSF    
end

