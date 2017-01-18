function computetca(sub)
% TCA computes and plots x and y offsets from interleaved videos recorded
% with AOSLO IV when the 'TCA' experiment has been used for stimulus
% presentation in AOMControl. The results are stored in tca_comp and saved
% as a .mat file.
%
% The 'compute_tca_core' function returns the x and y pixel offsets
% due to transverse chromatic aberration.  Assumes 3 interleaved
% fast-scan lines, representing IR, Red and Green channels (in that order)
% as well as a white cross representing the middle of the TCA area to be
% measured.
%
% 'frame' = 512x512 image to be analyzed, in floating-point values
% 'crossChannel' = string indicating which line contains the center
%                  of the cross: 'r', 'g', or 'ir'.
% 'showTCA' = flag where 1 means the TCA images will be displayed
% 'corrChannel' = string indicating correlation channel ('r' or 'ir')
%                 to be displayed
%
% Matrix returned is as follows:   [ IR/G row IR/G col
%                                    IR/R row IR/R col
%                                    R/G row  R/G col
%                                    R/IR row R/IR col ];
%
% DFT kernel function dftregistration.m from reference:
% Guizar-Sicairos M, Thurman ST, Fienup JR (2008) Efficient subpixel
% image registration algorithms. Optics letters 33:156-8.
% Download at: <a href="http://is.gd/bEwG43">http://is.gd/bEwG43</a>
%
%
% NOTE:
% =====
% Code was adjusted by BPS in 2016 to accomodate new orientation of fast
% and slow scanners.
import img.dftregistration

if nargin==0; %checks for subfield option
    sub=1;
end

global LOCX LOCY;
killfunc=0;

% some initial error handling
temptest=which('dftregistration');
if exist(temptest,'file')==0
    disp(' ')
    disp(' ')
    disp(' ')
    disp(' The core function dftregistration.m was not found in Matlab''s paths.')
    disp(' Either set the path, or download m-file at: <a href="http://is.gd/bEwG43">http://is.gd/bEwG43</a>')
    disp(' ')
    error('Script halted: dftregistration.m is missing');
end

[files, pathname]=uigetfile('*.avi','Select avi file(s) for TCA computation','MultiSelect', 'on');  % file selection dialog

if ~(isequal(files,0) || isequal(pathname,0)) % Checks if cancelled
    
    cd(pathname);           % do everything in video folder
    files=cellstr(files);   % convert to cells needed because n = 1 results in a string
    nfiles=size(files,2);   % determine number of files in selection
    nmats=0;
    idash = find(pathname==filesep());
    prefix = pathname(idash(end-1)+1:end-1);
    
    
    for nf = 1:nfiles
        vname = files{nf};  % set current filename
        matname = [vname(1:end-4),'_TCA.mat'];  % generate filename for .mat file to store
        
        if exist(matname,'file')==2
            nmats=nmats+1;
        end
    end
    
    combi = 'No';
    if nmats==nfiles && nfiles~=1
        combi = questdlg('Combine data?','Question','Yes', 'No', 'Yes');
        combi_data=[];
        combi_prefix=vname;
        combi_name=[''];
    end
    
    
    % main loop for number of videos in selection
    for nf = 1:nfiles
        LOCX=[];
        LOCY=[];
        
        vname = files{nf};  % set current filename
        matname = [vname(1:end-4),'_TCA.mat'];  % generate filename for .mat file to store
        
        if exist(matname,'file')==2   % if .mat file is already present
            
            load(matname)
            if strcmp(combi,'Yes') % do combination if chosen in question dlg
                combi_data=cat(3,combi_data,tca_comp);
                combi_name=strcat(combi_name,matname(end-11:end-8),'_');
            end
            
        else   % if .mat file is not present do the full calculation
                       
            % create a video reader object
            readerobj = VideoReader(vname);
            %nframes = readerobj.NumFrames;
            % Above field will be lost in future releases. Below should
            % work in that case.
            nframes = readerobj.Duration * readerobj.FrameRate;
            if sub==1
                tca_comp=zeros(2,2,nframes);
            else
                tca_comp=zeros(6,2,nframes);
            end
            
            try
                h = waitbar(0,'1','Name',['Computing TCA in ',vname,' ...'],...
                    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
                setappdata(h,'canceling',0)

                % Skip the first frame.
                readFrame(readerobj);
                f = 2;
                while hasFrame(readerobj)
                    if getappdata(h,'canceling')
                        killfunc = 1;
                        break
                    end
                    videoR=readFrame(readerobj);
                    t1=double(videoR);
                    % calls TCA computation core function
                    %delete(h);
                    tca_comp(:,:,f)=compute_tca_core(t1,'ir',0,'ir',sub, f);  
                    waitbar(f/nframes,h,sprintf('Frame %2.0f of %2.0f',f,nframes))
                    f = f + 1;
                end;
                delete(h);
                if killfunc
                    disp(' ');disp(' ');disp(' ')
                    disp(' --> TCA computation cancelled')
                    disp(' ');disp(' ');
                    return;
                end;
                save(matname,'tca_comp','LOCX','LOCY');     % save result to .mat file
                
            catch ME
                delete(h);
                error('Problem with compute_tca_core');
            end
        end
        
        plotTCA(tca_comp,matname,nf,sub);
        
    end
    
    if strcmp(combi,'Yes') % do combination if chosen in question dlg
        combi_name = ['Combined_',combi_name(1:end-1)];
        plotTCA(combi_data,combi_name,1,sub);
    end
    disp(' ');
    
else % 'Cancel' case
    disp(' ')
    disp(' --> TCA function cancelled')
    disp(' ')
    disp(' ')
    return
end


function y = compute_tca_core(frame,crossChannel,showTCA,corrChannel,sub, nframe)
import img.dftregistration
global LOCX LOCY;
skipframe=0;
frame=double(frame);
frame=frame/max(frame(:));
if sub==2 
    y=zeros(6,2); 
else
    y=zeros(2,2);
end
    

% construct cross filter and apply to frame
crossFilter=zeros(11); 
crossFilter(:,6)=1; 
crossFilter(6,:)=1;

% crossFilter=zeros(17); crossFilter(:,9)=1; crossFilter(9,:)=1; %depends on cross size

r = imfilter(frame, crossFilter); 
r=r/max(r(:));  % normalize 0 to 1
bw = im2bw(r,0.9); % binarize by thresholding

% locate cross's center
if size(bw(bw==1),1)==1 %only if frame contains cross
    if isempty(LOCX) % store locations only if not found before
        
        [locy, locx]=ind2sub([size(bw,1) size(bw,2)],find(bw==max(bw(:))));
        LOCX=locx; LOCY=locy; % locx,locy is position of cross center; x=column
    else
        locx=LOCX; locy=LOCY;
    end
else
    skipframe=1;
end

if ~skipframe % do the following only if cross was detected
    
    % assign offsets appropriate for cross's position
    switch lower(crossChannel)
        case {'g','green'}
            %    disp('Cross centered in Green channel');
            Ry=locy-60+0;  Rx=locx-127;
            Gy=locy-60+1;  Gx=locx-127;
            IRy=locy-60+2; IRx=locx-127;
        case {'r','red'}
            %    disp('Cross centered in Red channel');
            Ry=locy-60-1;  Rx=locx-127;
            Gy=locy-60+0;  Gx=locx-127;
            IRy=locy-60+1; IRx=locx-127;
        case {'ir','infrared'}
            %     disp('Cross centered in IR channel');
            IRy=locy-60-1;  IRx=locx-127;
            Gy=locy-60-2;  Gx=locx-127;
            Ry=locy-60+0; Rx=locx-127;
        otherwise
            disp('Channel with cross is invalid.')
    end;
    
    % extract regions of frame for TCA calculation
    stimheight=125;
    R=frame(Ry:3:Ry+stimheight, Rx:Rx+255);
    G=frame(Gy:3:Gy+stimheight, Gx:Gx+255);
    IR=frame(IRy:3:IRy+stimheight, IRx:IRx+255);
    

    % subfield regions, left and rright half
    R1=frame(Ry:3:Ry+stimheight, Rx:Rx+122);
    G1=frame(Gy:3:Gy+stimheight, Gx:Gx+122);
    IR1=frame(IRy:3:IRy+stimheight, IRx:IRx+122);
   
    R2=frame(Ry+133:3:Ry+stimheight, Rx:Rx+255);
    G2=frame(Gy+133:3:Gy+stimheight, Gx:Gx+255);
    IR2=frame(IRy+133:3:IRy+stimheight, IRx:IRx+255);
    
    % remove cross artifact  NOTE now assumes cross in IR channel !!!!!!!!
    meanIR = mean(IR(:)); 
    IR(20:24, 128) = meanIR;
    
    meanG = mean(G(:)); 
    G(19:23, 128) = meanG;
    G(19, 126:30) = meanG;
    
    meanR = mean(R(:)); 
    R(19:23, 128) = meanR; 
    R(21, 122:133) = meanR;

    % Plot a frame of each channel to see what you are correlating (sanity
    % check).
    if nframe == 10
     figure(2); 
     subplot(3, 1, 1); imshow(G); title('green channel');
     subplot(3, 1, 2); imshow(R); title('red channel');
     subplot(3, 1, 3); imshow(IR); title('IR channel');
    end
    
    %flip to match fundus view -- No longer needed on current system (2016)
    %R=flipud(R); G=flipud(G); IR=flipud(IR);
    %R1=flipud(R1); G1=flipud(G1); IR1=flipud(IR1);
    %R2=flipud(R2); G2=flipud(G2); IR2=flipud(IR2);
    
    % ---- do 2-D cross-correlation ---- %
    % green to IR
    [outputIRG, ~] = dftregistration(fft2(IR), fft2(G), 32);
    y(1, 1) = outputIRG(1, 4);
    
    % red to IR
    [outputIRR, ~] = dftregistration(fft2(IR), fft2(R), 32);
    y(2, 1) = outputIRR(1, 4);
    
    % correct the y axis for the downsampling that occurs due to the
    % interleaved nature of the stimulus
    y(1, 2) = (outputIRG(1, 3) - 0.6) * 3 + 2;
    y(2, 2) = (outputIRR(1, 3) - 0.3) * 3 + 1;
    % ---------------------------------- %

    if sub==2
        [outputIRG1, ~]=dftregistration(fft2(IR1),fft2(G1),32);
        y(3,1) = (outputIRG1(1,4)-.3)*3+1;
        y(3,2) = outputIRG1(1,3);
        [outputIRR1, ~]=dftregistration(fft2(IR1),fft2(R1),32);
        y(4,1) = (outputIRR1(1,4)-.6)*3+2;
        y(4,2) = outputIRR1(1,3);

        [outputIRG2, ~]=dftregistration(fft2(IR2),fft2(G2),32);
        y(5,1) = (outputIRG2(1,4)-.3)*3+1;
        y(5,2) = outputIRG2(1,3);
        [outputIRR2, ~]=dftregistration(fft2(IR2),fft2(R2),32);
        y(6,1) = (outputIRR2(1,4)-.6)*3+2;
        y(6,2) = outputIRR2(1,3);
    end
    
    
%     %disp('IR-R displacement (row, col)'); disp(y(2,:));
%     [outputRG temp]=dftregistration(fft2(R),fft2(G),32);
%     y(3,1) = (outputRG(1,4)-.3)*3+1;
%     y(3,2) = outputRG(1,3);
%     %disp('R-G displacement (row, col)'); disp(y(3,:));
%     [outputRIR temp]=dftregistration(fft2(R),fft2(IR),32);
%     y(4,1) = (outputRIR(1,4)-.6)*3+2;
%     y(4,2) = outputRIR(1,3);
%     %disp('R-IR displacement (row, col)'); disp(y(4,:));
%     
    % show figure of TCA shifts, if desired
    if showTCA==1
        figure; colormap grayscale
        [rr cc]=size(R);
        rr=rr/2; cc=cc/2;
        switch lower(corrChannel)
            case {'r','red'}
                disp('Correlate against Red channel');
                subplot(1,3,1); hold on;
                imagesc(R); title ('680nm'); axis(.5+[0 cc*2 0 rr*2]); caxis([0 255]);
                plot(cc,rr,'wo');
                subplot(1,3,2); hold on
                imagesc(G); title ('545nm'); axis(.5+[0 cc*2 0 rr*2]); caxis([0 255]);
                plot(cc-outputRG(1,4),rr-outputRG(1,3),'co');
                plot([cc cc-outputRG(1,4)],[rr rr-outputRG(1,3)],'g');
                subplot(1,3,3); hold on
                imagesc(IR); title ('840nm'); axis(.5+[0 cc*2 0 rr*2]); caxis([0 255]);
                plot(cc-outputRIR(1,4),rr-outputRIR(1,3),'co');
                plot([cc cc-outputRIR(1,4)],[rr rr-outputRIR(1,3)],'r');
            case {'ir','infrared'}
                disp('Correlate against IR channel');
                subplot(1,3,1); hold on;
                imagesc(R); title ('680nm'); axis(.5+[0 cc*2 0 rr*2]); caxis([0 255]);
                plot(cc-outputIRR(1,4),rr-outputIRR(1,3),'co');
                plot([cc cc-outputIRR(1,4)],[rr rr-outputIRR(1,3)],'r');
                subplot(1,3,2); hold on
                imagesc(G); title ('545nm'); axis(.5+[0 cc*2 0 rr*2]); caxis([0 255]);
                plot(cc-outputIRG(1,4),rr-outputIRG(1,3),'co');
                plot([cc cc-outputIRG(1,4)],[rr rr-outputIRG(1,3)],'g');
                subplot(1,3,3); hold on
                imagesc(IR); title ('840nm'); axis(.5+[0 cc*2 0 rr*2]); caxis([0 255]);
                plot(cc,rr,'wo');
            otherwise
                disp('corrChannel must be R or IR.')
        end;
    end;

else % case when no cross is found
    y(1,1) = nan; y(1,2) = nan;
    y(2,1) = nan; y(2,2) = nan;
    if sub==2
        y(3,1) = nan; y(3,2) = nan;
        y(4,1) = nan; y(4,2) = nan;
        y(5,1) = nan; y(5,2) = nan;
        y(6,1) = nan; y(6,2) = nan;
    end
end;




function plotTCA(tca_comp,matname,plotsi,sub)

% read data from result matrix
nframes = size(squeeze(tca_comp(1,1,:)),1);
gx=squeeze(tca_comp(1,1,:));
gy=squeeze(tca_comp(1,2,:));
rx=squeeze(tca_comp(2,1,:));
ry=squeeze(tca_comp(2,2,:));

% do slope analysis to find clusters
n=size(gx,1);
mink=5; %determines how many STD windows are averaged
maxk=10;
samplerange=3; %

% calculate STDs for ordered offset values for different window sizes
for k=mink:maxk
    slidew=k;
    nslides=n-slidew;
    [sortgx isgx] = sort(gx);
    [sortgy isgy] = sort(gy);
    [sortrx isrx] = sort(rx);
    [sortry isry] = sort(ry);
    for j=1:nslides
        sxg(k-mink+1,j)=std(sortgx(j:j+slidew));
        syg(k-mink+1,j)=std(sortgy(j:j+slidew));
        sxr(k-mink+1,j)=std(sortrx(j:j+slidew));
        syr(k-mink+1,j)=std(sortry(j:j+slidew));
    end
end

b = mean(sxg);
minb=find(b==min(b(1:end-maxk)));
minb=minb(round(size(minb,2)/2));
cxg =sortgx(minb);
cyg = gy(isgx(minb));

samplegx=intersect(find(gx>=cxg-samplerange),find(gx<=cxg+samplerange));
samplegy=intersect(find(gy>=cyg-samplerange),find(gy<=cyg+samplerange));

mcxg=median(gx(samplegx));
mcyg=median(gy(samplegy));

% b = mean(syg);
% minb=find(b==min(b));
% minb=minb(round(size(minb,2)/2));
% cyg=sortgy(minb);

b = mean(sxr);
minb=find(b==min(b(1:end-maxk)));
minb=minb(round(size(minb,2)/2));
cxr=sortrx(minb);
cyr = ry(isrx(minb));

samplerx=intersect(find(rx>=cxr-samplerange),find(rx<=cxr+samplerange));
samplery=intersect(find(ry>=cyr-samplerange),find(ry<=cyr+samplerange));

mcxr=median(rx(samplerx));
mcyr=median(ry(samplery));

cr=[1 0 0];
cr2=[0.7 0 0];
cr3=[1 0.75 0.75];
cr4=[1 0.5 0.5];
cg=[0 0.7 0];
cg2=[0 0.5 0];
cg3=[0.75 1 0.75];
cg4=[0.5 1 0.5];
cd1=[0.5 0.5 0.5];
cd2=[0.2 0.2 0.2];

figure;hold on
plot(gx,gy,'.','Color',cg3);
plot(rx,ry,'.','Color',cr3);
axis equal; grid on;
axis square;
axis([-30 30 -30 30])
xlabel('row pixels'); ylabel('col pixels');
title([matname,' fullsize'],'Interpreter','none');

plot(nanmedian(gx),nanmedian(gy),'o','Color',cg)
plot(cxg,cyg,'x','Color',cg)
plot(mcxg,mcyg,'.','Color',cg)

legend('IR/G','IR/R','Median','Centroid simple', 'Centroid 2 step');

plot(nanmedian(rx),nanmedian(ry),'o','Color',cr)
plot(cxr,cyr,'x','Color',cr)
plot(mcxr,mcyr,'.','Color',cr)

if plotsi==1; 
    display(' RX      RY      GX      GY  '); 
end;  % output cluster fits coordinates
display([' ',num2str(mcxr),'  ', num2str(mcyr),'  ', num2str(mcxg),'  ', num2str(mcyg)])


if sub==2
    
    
% read data from result matrix
nframes = size(squeeze(tca_comp(1,1,:)),1);
gx=squeeze(tca_comp(3,1,:));
gy=squeeze(tca_comp(3,2,:));
rx=squeeze(tca_comp(4,1,:));
ry=squeeze(tca_comp(4,2,:));

% do slope analysis to find clusters
n=size(gx,1);
mink=5; %determines how many STD windows are averaged
maxk=10;
samplerange=3; %

% calculate STDs for ordered offset values for different window sizes
for k=mink:maxk
    slidew=k;
    nslides=n-slidew;
    [sortgx isgx] = sort(gx);
    [sortgy isgy] = sort(gy);
    [sortrx isrx] = sort(rx);
    [sortry isry] = sort(ry);
    for j=1:nslides
        sxg(k-mink+1,j)=std(sortgx(j:j+slidew));
        syg(k-mink+1,j)=std(sortgy(j:j+slidew));
        sxr(k-mink+1,j)=std(sortrx(j:j+slidew));
        syr(k-mink+1,j)=std(sortry(j:j+slidew));
    end
end

b = mean(sxg);
minb=find(b==min(b(1:end-maxk)));
minb=minb(round(size(minb,2)/2));
cxg =sortgx(minb);
cyg = gy(isgx(minb));

samplegx=intersect(find(gx>=cxg-samplerange),find(gx<=cxg+samplerange));
samplegy=intersect(find(gy>=cyg-samplerange),find(gy<=cyg+samplerange));

mcxg=median(gx(samplegx));
mcyg=median(gy(samplegy));

% b = mean(syg);
% minb=find(b==min(b));
% minb=minb(round(size(minb,2)/2));
% cyg=sortgy(minb);

b = mean(sxr);
minb=find(b==min(b(1:end-maxk)));
minb=minb(round(size(minb,2)/2));
cxr=sortrx(minb);
cyr = ry(isrx(minb));

samplerx=intersect(find(rx>=cxr-samplerange),find(rx<=cxr+samplerange));
samplery=intersect(find(ry>=cyr-samplerange),find(ry<=cyr+samplerange));

mcxr=median(rx(samplerx));
mcyr=median(ry(samplery));

cr=[1 0 0];
cr2=[0.7 0 0];
cr3=[1 0.75 0.75];
cr4=[1 0.5 0.5];
cg=[0 0.7 0];
cg2=[0 0.5 0];
cg3=[0.75 1 0.75];
cg4=[0.5 1 0.5];
cd1=[0.5 0.5 0.5];
cd2=[0.2 0.2 0.2];

figure;hold on
plot(gx,gy,'.','Color',cg3);
plot(rx,ry,'.','Color',cr3);
axis equal; grid on;
axis square;
axis([-30 30 -30 30])
xlabel('row pixels'); ylabel('col pixels');
title([matname,' upper half'],'Interpreter','none');

plot(nanmedian(gx),nanmedian(gy),'o','Color',cg)
plot(cxg,cyg,'x','Color',cg)
plot(mcxg,mcyg,'.','Color',cg)

legend('IR/G','IR/R','Median','Centroid simple', 'Centroid 2 step');

plot(nanmedian(rx),nanmedian(ry),'o','Color',cr)
plot(cxr,cyr,'x','Color',cr)
plot(mcxr,mcyr,'.','Color',cr)

display([' ',num2str(mcxr),'  ', num2str(mcyr),'  ', num2str(mcxg),'  ', num2str(mcyg)])



% read data from result matrix
nframes = size(squeeze(tca_comp(1,1,:)),1);
gx=squeeze(tca_comp(5,1,:));
gy=squeeze(tca_comp(5,2,:));
rx=squeeze(tca_comp(6,1,:));
ry=squeeze(tca_comp(6,2,:));

% do slope analysis to find clusters
n=size(gx,1);
mink=5; %determines how many STD windows are averaged
maxk=10;
samplerange=3; %

% calculate STDs for ordered offset values for different window sizes
for k=mink:maxk
    slidew=k;
    nslides=n-slidew;
    [sortgx isgx] = sort(gx);
    [sortgy isgy] = sort(gy);
    [sortrx isrx] = sort(rx);
    [sortry isry] = sort(ry);
    for j=1:nslides
        sxg(k-mink+1,j)=std(sortgx(j:j+slidew));
        syg(k-mink+1,j)=std(sortgy(j:j+slidew));
        sxr(k-mink+1,j)=std(sortrx(j:j+slidew));
        syr(k-mink+1,j)=std(sortry(j:j+slidew));
    end
end

b = mean(sxg);
minb=find(b==min(b(1:end-maxk)));
minb=minb(round(size(minb,2)/2));
cxg =sortgx(minb);
cyg = gy(isgx(minb));

samplegx=intersect(find(gx>=cxg-samplerange),find(gx<=cxg+samplerange));
samplegy=intersect(find(gy>=cyg-samplerange),find(gy<=cyg+samplerange));

mcxg=median(gx(samplegx));
mcyg=median(gy(samplegy));

% b = mean(syg);
% minb=find(b==min(b));
% minb=minb(round(size(minb,2)/2));
% cyg=sortgy(minb);

b = mean(sxr);
minb=find(b==min(b(1:end-maxk)));
minb=minb(round(size(minb,2)/2));
cxr=sortrx(minb);
cyr = ry(isrx(minb));

samplerx=intersect(find(rx>=cxr-samplerange),find(rx<=cxr+samplerange));
samplery=intersect(find(ry>=cyr-samplerange),find(ry<=cyr+samplerange));

mcxr=median(rx(samplerx));
mcyr=median(ry(samplery));

cr=[1 0 0];
cr2=[0.7 0 0];
cr3=[1 0.75 0.75];
cr4=[1 0.5 0.5];
cg=[0 0.7 0];
cg2=[0 0.5 0];
cg3=[0.75 1 0.75];
cg4=[0.5 1 0.5];
cd1=[0.5 0.5 0.5];
cd2=[0.2 0.2 0.2];

figure;hold on
plot(gx,gy,'.','Color',cg3);
plot(rx,ry,'.','Color',cr3);
axis equal; grid on;
axis square;
axis([-30 30 -30 30])
xlabel('row pixels'); ylabel('col pixels');
title([matname,' lower half'],'Interpreter','none');

plot(nanmedian(gx),nanmedian(gy),'o','Color',cg)
plot(cxg,cyg,'x','Color',cg)
plot(mcxg,mcyg,'.','Color',cg)

legend('IR/G','IR/R','Median','Centroid simple', 'Centroid 2 step');

plot(nanmedian(rx),nanmedian(ry),'o','Color',cr)
plot(cxr,cyr,'x','Color',cr)
plot(mcxr,mcyr,'.','Color',cr)

display([' ',num2str(mcxr),'  ', num2str(mcyr),'  ', num2str(mcxg),'  ', num2str(mcyg)])

end
