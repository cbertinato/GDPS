  
% Readfiles in AT1M file format.m
% Read ATM1 format data files
% This script concatenates more that one file
% By Daniel Aliod
% Broomfield August, April 2014

clc;
clear;
close all;
sampling=1;
Per=1/sampling;
Meteroffset=10000;

Prefiltcorr=0; % 1 for compensate for the antialising filter
filtertype=0; % if type=0 Blackman, if type=1 Gausian
CCcorr=1; % 1 for using cross coupling correction

ReadMeterConfig; % read configuration vues
Levelcorr=str2double(Levelcorr);
sensortime=str2double(sensortime);
filtertime=str2double(filtertime); % of the exported lines
kfactor=str2double(kfactor);
filtertype=str2double(filtertype);

monitors_comp=str2double(monitors_comp);
ve_comp=str2double(ve_comp);
vcc_comp=str2double(vcc_comp);
lc_comp=str2double(lc_comp);
xc_comp=str2double(xc_comp);


drift=str2double(PreStillReading)-str2double(PosStillReading);
drift=drift+0.00001; % calculate total drift
TideGravity=str2double(Tieg);
PreTieReading=str2double(PreStillReading);
% offset=str2double(Tieg)-kfactor*str2double(PreStillReading)+Meteroffset;
gravoffset=str2double(Tieg)-kfactor*str2double(PreStillReading);
fprintf('\n');
fprintf('Meter Offset in Tie %f \n',gravoffset);

% --------------------------------------------------
%  Calculate the filter coefficients

 filterlength=filtertime;    % 
 Taps=2*filterlength; % 
 B = fir1(Taps,1/Taps,blackman(Taps+1));
 % filter for timming
 tTap=3;
 Bt = fir1(tTap,1/tTap,blackman(tTap+1));
 
 % filter for cross correlation monitor cross correlation
 ccTap=240; % 60 sec filter
 Bcc = fir1(ccTap,1/ccTap,blackman(ccTap+1));
  %  gravoffset=979930 % Meter gravity offset
% gravoffset=9.797694267118904e+05-10126+ 2.116455702752137e+02-210;

% init the env data structure
dat.QCgrav=[]; 
dat.grv = [];
dat.laccel = [];
dat.xaccel =[];
dat.beam=[];

dat.temp =[];
dat.status=[];
dat.checksum=[];
dat.pressure =[];
dat.Etemp=[];
dat.ve = [];
dat.vcc = [];
dat.al = [];
dat.ax =[];
dat.Y=[];
dat.M=[];
dat.D=[];
dat.h=[];
dat.m=[];
dat.s=[];
dat.lat=[];
dat.long=[];
dat.speed=[];
dat.course=[];

% -----------
CC = inputdlg('First line?','Format',1,{'Y'});
 CC = char(CC);
    if CC=='Y' 
     delete thelines.mat;   
     noflines=0;  
    else
     load thelines;   
    end

n = inputdlg('Drift from start end','Line',1,{'0'});
drift= str2num(char(n));
drift=drift+0.00001;
    

 Morefiles='Y';
 while Morefiles=='Y'
 % do things

 % do things
  [file p] = uigetfile('p\*.*','Load DGS file');
  fname=[p file] ;
  save oldpath  p;
  % Now get the data   

in=ReadAT1M(fname);
fprintf('Readed file %s \n',fname); 

% extact time info
 
CC = inputdlg('Add more files?','Load files',1,{'N'});
Morefiles = char(CC);

dat.QCgrav=[dat.QCgrav;in.QCgravity]; 
dat.grv = [dat.grv;in.gravity];
dat.laccel = [dat.laccel;in.long];
dat.xaccel =[dat.xaccel;in.cross];
dat.beam=[dat.beam;in.beam];

dat.temp =[dat.temp;in.temp];
dat.status=[dat.status;in.status];
dat.checksum=[dat.checksum;in.checksum];
dat.pressure =[dat.pressure;in.pressure];
dat.Etemp=[dat.Etemp;in.Etemp];
dat.ve = [dat.ve;in.ve];
dat.vcc = [dat.vcc;in.vcc];
dat.al = [dat.al;in.al];
dat.ax =[dat.ax;in.ax];

dat.Y=[dat.Y;in.Y];
dat.M=[dat.M;in.M];
dat.D=[dat.D;in.D];
dat.h=[dat.h;in.h];
dat.m=[dat.m;in.m];
dat.s=[dat.s;in.s];
dat.lat=[dat.lat;in.latitude];
dat.long=[dat.long;in.longitude];
dat.speed=[dat.speed;in.speed];
dat.course=[dat.course;in.course];
end;  

% Generate Long and cross accelerations from on board 
% real time GPS or INS for performance calculations or marine use
% when a good quality real time navegation is provided in the GPS input

dat.speed=0.514444*dat.speed; % conver knots to m/s
[rt_Evel,rt_Nvel] = LatLon2VeVn(dat.lat,dat.long);
    rt_Evel=sampling*rt_Evel; 
    rt_Nvel=sampling*rt_Nvel;
  % calculate North and East accelerations
  rt_Eacc=1e5*sampling*convn(rt_Evel,tay10','same');
  rt_Nacc=1e5*sampling*convn(rt_Nvel,tay10','same');
    
 [rt_crse,rt_vel] =VeVn2CseVel(rt_Evel,rt_Nvel);
 [rt_acccross,rt_acclong]=ENacc2Body(rt_crse,rt_Eacc,rt_Nacc);
 
  % all this velocities and accelerations are used for simulation
  % and verification pourposes
  % **************************************************************    
    
metertime=datenum(dat.Y,dat.M,dat.D,dat.h,dat.m,dat.s)*24*3600+sensortime; % seconds
numtimetide=metertime/24/3600;
startdata=metertime(1);
enddata=metertime(end);

interval=diff(metertime);

Gaps=find(abs(interval) > Per*1.1);
if (~isempty(Gaps))
uiwait(msgbox('Data gaps detected continue?','Message','none'));
plot(interval);

CC = inputdlg('Crop data or fill the gaps? C F','Format',1,{'C'});
        CC = char(CC);
        if CC=='C' 
            
         [pos,g] = ginput(2);
          x=round(pos(1));
          y=round(pos(2));
           
        dat.QCgrav=dat.QCgrav(x:y);
        dat.grv =dat.grv(x:y);
        dat.laccel =dat.laccel(x:y);
        dat.xaccel =dat.xaccel(x:y);
        dat.beam=dat.beam(x:y);
        dat.temp =dat.temp(x:y);
        dat.status=dat.status(x:y);
        dat.checksum=dat.checksum(x:y);
        dat.pressure =dat.pressure(x:y);
        dat.Etemp=dat.Etemp(x:y);
        dat.ve =dat.ve(x:y); 
        dat.vcc =dat.vcc(x:y);
        dat.al=dat.al(x:y);
        dat.ax =dat.ax(x:y);

        dat.Y=dat.Y(x:y);
        dat.M=dat.M(x:y);
        dat.D=dat.D(x:y);
        dat.h=dat.h(x:y);
        dat.m=dat.m(x:y);
        dat.s=dat.s(x:y);
        dat.lat=dat.lat(x:y);
        dat.long=dat.long(x:y);
        dat.speed=dat.speed(x:y);
        dat.course=dat.course(x:y);
        metertime=metertime(x:y);
        numtimetide=numtimetide(x:y);
        startdata=metertime(1);
        enddata=metertime(end);   
        
        % check for more Gaps after the crop
        
        interval=diff(metertime);
        Gaps=find(abs(interval) > Per+Per*0.1);
        if (~isempty(Gaps))
        uiwait(msgbox('Data gaps detected continue?','Message','none'));
        plot(interval);
        
        
        
        dt = mode(interval);
         nom_end=round((metertime(end)-metertime(1))/dt + 1);
         t1 =metertime(1);
         timeind = round((metertime - t1)/dt + 1);
         tcorrmeter = linspace(metertime(1),metertime(end),nom_end)'; 
         miss=find(interval > dt+0.1);
            
        
         dat.QCgrav=MissNaNs(dat.QCgrav,timeind,nom_end); 
         g1=dat.grv;
         dat.grv=MissNaNs( dat.grv,timeind,nom_end); 
         dat.laccel=MissNaNs( dat.laccel,timeind,nom_end); 
         dat.xaccel=MissNaNs(dat.xaccel,timeind,nom_end); 
         dat.beam=MissNaNs( dat.beam,timeind,nom_end); 
         dat.temp=MissNaNs(dat.temp,timeind,nom_end); 
       % dat.status=MissNaNs(dat.status,timeind,nom_end); 
       % dat.checksum=MissNaNs( dat.checksum,timeind,nom_end); 
         dat.pressure=MissNaNs(dat.pressure,timeind,nom_end); 
         dat.Etemp=MissNaNs(dat.Etemp,timeind,nom_end); 
         dat.ve=MissNaNs(dat.ve,timeind,nom_end); 
         dat.vcc=MissNaNs(dat.vcc,timeind,nom_end); 
         dat.al=MissNaNs(dat.al,timeind,nom_end); 
         dat.ax=MissNaNs(dat.ax,timeind,nom_end); 
         dat.lat=MissNaNs(dat.lat,timeind,nom_end); 
         dat.long=MissNaNs(dat.long,timeind,nom_end); 
         dat.speed=MissNaNs(dat.speed,timeind,nom_end); 
         dat.course=MissNaNs(dat.course,timeind,nom_end); 
         
         
         dat.QCgrav=FillDataGaps(dat.QCgrav);  
         dat.grv=FillDataGaps(dat.grv);  
         dat.xaccel=FillDataGaps( dat.xaccel);  
         dat.laccel=FillDataGaps(dat.laccel);  
         dat.beam=FillDataGaps(dat.beam);  
         dat.temp=FillDataGaps(dat.temp);  
         dat.pressure=FillDataGaps(dat.pressure);  
         dat.Etemp=FillDataGaps(dat.Etemp);   
         dat.ve=FillDataGaps(dat.ve);  
         dat.vcc=FillDataGaps(dat.vcc);
         dat.al=FillDataGaps(dat.al);  
         dat.ax=FillDataGaps(dat.ax);  
         dat.lat=FillDataGaps(dat.lat);  
         dat.long=FillDataGaps(dat.long);  
         dat.speed=FillDataGaps(dat.speed);  
         dat.course=FillDataGaps(dat.course);  
         
         metertime= tcorrmeter;
         startdata=metertime(1);
         enddata=metertime(end);   
        end
       
        else
            
         dt = mode(interval);
         nom_end=round((metertime(end)-metertime(1))/dt + 1);
         t1 =metertime(1);
         timeind = round((metertime - t1)/dt + 1);
         tcorrmeter = linspace(metertime(1),metertime(end),nom_end)'; 
         miss=find(interval > dt+0.1);
            
         
         dat.QCgrav=MissNaNs(dat.QCgrav,timeind,nom_end); 
         dat.grv=MissNaNs( dat.grv,timeind,nom_end); 
         dat.laccel=MissNaNs( dat.laccel,timeind,nom_end); 
         dat.xaccel=MissNaNs(dat.xaccel,timeind,nom_end); 
         dat.beam=MissNaNs( dat.beam,timeind,nom_end); 
         dat.temp=MissNaNs(dat.temp,timeind,nom_end); 
         dat.status=MissNaNs(dat.status,timeind,nom_end); 
         dat.checksum=MissNaNs( dat.checksum,timeind,nom_end); 
         dat.pressure=MissNaNs(dat.pressure,timeind,nom_end); 
         dat.Etemp=MissNaNs(dat.Etemp,timeind,nom_end); 
         dat.ve=MissNaNs(dat.ve,timeind,nom_end); 
         dat.vcc=MissNaNs(dat.vcc,timeind,nom_end); 
         dat.al=MissNaNs(dat.al,timeind,nom_end); 
         dat.ax=MissNaNs(dat.ax,timeind,nom_end); 
         dat.lat=MissNaNs(dat.lat,timeind,nom_end); 
         dat.long=MissNaNs(dat.long,timeind,nom_end); 
         dat.speed=MissNaNs(dat.speed,timeind,nom_end); 
         dat.course=MissNaNs(dat.course,timeind,nom_end); 
            
            
         dat.QCgrav=FillDataGaps(dat.QCgrav); 
         dat.grv=FillDataGaps( dat.grv); 
         dat.laccel=FillDataGaps( dat.laccel); 
         dat.xaccel=FillDataGaps(dat.xaccel); 
         dat.beam=FillDataGaps( dat.beam); 
         dat.temp=FillDataGaps(dat.temp); 
         dat.status=FillDataGaps(dat.status); 
         dat.checksum=FillDataGaps( dat.checksum); 
         dat.pressure=FillDataGaps(dat.pressure); 
         dat.Etemp=FillDataGaps(dat.Etemp); 
         dat.ve=FillDataGaps(dat.ve); 
         dat.vcc=FillDataGaps(dat.vcc); 
         dat.al=FillDataGaps(dat.al); 
         dat.ax=FillDataGaps(dat.ax); 
         dat.lat=FillDataGaps(dat.lat); 
         dat.long=FillDataGaps(dat.long); 
         dat.speed=FillDataGaps(dat.speed); 
         dat.course=FillDataGaps(dat.course); 
                       
         metertime= tcorrmeter;
        startdata=metertime(1);
        enddata=metertime(end);   
      end

end

% correct Monitor for meter filter delay

        if(Prefiltcorr==1)
        load MeterFilterModel;
        
        x1=resample(dat.ve,10,1);
         x2=resample(dat.vcc,10,1);
          x3=resample(dat.al,10,1);
           x4=resample(dat.ax,10,1);
        
        
        dat.ve=filter(meterfilt,1,x1);
        dat.vcc=filter(meterfilt,1,x2);
        dat.al=filter(meterfilt,1,x3);
        dat.ax=filter(meterfilt,1,x4);
        
        
       dat.ve=resample(dat.ve,1,10);
       dat.vcc=resample(dat.vcc,1,10);
       dat.al=resample(dat.al,1,10);
       dat.ax=resample(dat.ax,1,10);
        
     %  dat.ve=dat.ve(20:end-20);
     %  dat.vcc=dat.vcc(20:end-20);
     %  dat.al=dat.al(20:end-20);
     %  dat.ax=dat.ax(20:end-20);
       
        
        end


driftcorr= linspace(0,drift,length(metertime)); 

% fprintf('start data %f \n',startdata);
% fprintf('end data %f \n',enddata);
% fprintf('total seconds %f \n',enddata-startdata);

% make more monitors


bx=dat.beam.*dat.xaccel; % Xcc is VCC in cross direction
al2=1e-6*dat.grv.*dat.laccel.^2;
ax2=1e-6*dat.grv.*dat.xaccel.^2;
x2=1e-2*dat.xaccel.^2;
l2=1e-2*dat.laccel.^2;

tide=LongmanTidePredictor(dat.long,dat.lat,metertime/24/3600); % calculate tidal effect


 % fing Gaps
% interval=diff(dat.time);
% Gaps=find(interval > Per+0.005);
% if (~isempty(Gaps))
% uiwait(msgbox('Data gaps detected continue?','Message','none'));
% end;
% eliminate GPS dropouts



% filter before plotting
 % fgpsacc=filter(B,1,gpsacc);
 

  fdat.laccel=filtfilt(B,1,dat.laccel);
  fdat.xaccel=filtfilt(B,1,dat.xaccel);
  fdat.beam=filtfilt(B,1,dat.beam);
  fdat.temp=filtfilt(B,1,dat.temp);
  fdat.pressure=filtfilt(B,1,dat.pressure);
  fdat.Etemp=filtfilt(B,1,dat.Etemp);
  fdat.ve=filtfilt(B,1,dat.ve);
  fdat.vcc=filtfilt(B,1,dat.vcc);
  fdat.al=filtfilt(B,1,dat.al);
  fdat.ax=filtfilt(B,1,dat.ax);
%  fdat.time=filtfilt(B,1,metertime); % don't filter !!!!!!!!!!!!!!!!!!!!!!
  fdat.lat=filtfilt(B,1,dat.lat);
  fdat.long=filtfilt(B,1,dat.long);
  fdat.speed=filtfilt(B,1,dat.speed);
  fdat.course=filtfilt(B,1,dat.course);
    
  fccgrav=filtfilt(Bcc,1,dat.grv);     % meter  gravity filtered for cross correlation
  fdat.cve=filtfilt(Bcc,1,dat.ve);
  fdat.cvcc=filtfilt(Bcc,1,dat.vcc);
  fdat.cal=filtfilt(Bcc,1,dat.al);
  fdat.cax=filtfilt(Bcc,1,dat.ax);
  fdat.l2=fdat.laccel.*fdat.laccel;
  fdat.x2=fdat.xaccel.*fdat.xaccel;
    
    if (CCcorr==1)
   % load Gains ve_coef vcc_coef  al_coef  ax_coef  l2_coef  x2_coef ; 
 % use file values  
 l2_coef=0;  
  x2_coef=0;
 vcc_coef=2.738;
ve_coef=-6.584;
al_coef=7.7;
ax_coef=0.27;
    fgrav_nocc=kfactor*filtfilt(B,1,dat.grv)-driftcorr'+gravoffset; % no cross coupling
    fgrav=kfactor*filtfilt(B,1,dat.grv)-driftcorr'+gravoffset+ve_coef*fdat.ve+vcc_coef*fdat.vcc+al_coef*fdat.al+... 
    ax_coef*fdat.ax+l2_coef*fdat.l2+x2_coef*fdat.x2;    % meter  gravity
   
    else
    fgrav=kfactor*filtfilt(B,1,dat.grv)-driftcorr'+gravoffset;     % meter  gravity    
    end    
    
    % new monitors
    fbx=filtfilt(B,1,bx);
    cbx=filtfilt(Bcc,1,bx);
    fal2=filtfilt(B,1,al2);
    cal2=filtfilt(Bcc,1,al2);
    fax2=filtfilt(B,1,ax2);
    cax2=filtfilt(Bcc,1,ax2);
    fx2=filtfilt(B,1,x2);
    cx2=filtfilt(Bcc,1,x2);
    fl2=filtfilt(B,1,l2);
    cl2=filtfilt(Bcc,1,l2);
    



 % aux filtering for timming syncronitztion  
 

% tgravity=dat.grv+P(1)*dat.ve+P(2)*dat.vcc+P(3)*dat.al+P(4)*dat.ax+P(5)*bx+P(6)*al2+P(7)*ax2+P(8)*l2+P(9)*x2; 

ftiming_Meter=filtfilt(Bt,1,dat.grv); % 
tlongacc=filtfilt(Bt,1,dat.laccel); % 

  

% decode STATUS bits
 clamp=bitget(dat.status,1);
 unclamp=bitget(dat.status,2);
 GPSsync=bitget(dat.status,3);
 feedback=bitget(dat.status,4);
 R1=bitget(dat.status,5);
 R2=bitget(dat.status,6);
 ADlock=bitget(dat.status,7);
 Rcvd=bitget(dat.status,8);
 NavMod1=bitget(dat.status,9);
 NavMod2=bitget(dat.status,10);
 PlatCom=bitget(dat.status,11);
 SensCom=bitget(dat.status,12);
 GPStime=bitget(dat.status,13);
  ADsat=bitget(dat.status,14);
 
 
scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('Data');
 ax1=subplot(4,1,1);
 plot(fgrav(Taps:end)),title('Gravity');
 ax2=subplot(4,1,2);
 plot(fdat.Etemp(Taps:end)),title('Etemp');
 ax3=subplot(4,1,3);
 plot(fdat.beam(Taps:end)),title('Beam');
 ax(4)=subplot(4,1,4);
 plot(fdat.temp(Taps:end)),title('Meter temp');    
 linkaxes([ax1 ax2 ax3],'x');


  scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('Data');
 ax1=subplot(4,1,1);
 plot(fgrav(Taps:end)),title('Gravity');
 ax2=subplot(4,1,2);
 plot(fdat.laccel(Taps:end)),title('Long');
 ax3=subplot(4,1,3);
 plot(fdat.xaccel(Taps:end)),title('Cross');
 ax(4)=subplot(4,1,4);
 plot(dat.QCgrav(Taps:end)),title('QCgravity');    
 linkaxes([ax1 ax2 ax3],'x');
 
   scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('Data');
 ax1=subplot(4,1,1);
 plot(fdat.ve(Taps:end)),title('ve');
 ax2=subplot(4,1,2);
 plot(fdat.vcc(Taps:end)),title('vcc');
 ax3=subplot(4,1,3);
 plot(fdat.al(Taps:end)),title('al');
 ax(4)=subplot(4,1,4);
 plot(fdat.ax(Taps:end)),title('ax');    
 linkaxes([ax1 ax2 ax3],'x');

 
 scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('Data');
 ax1=subplot(4,1,1);
 plot(fgrav(Taps:end)),title('Gravity');
 ax2=subplot(4,1,2);
 plot(NavMod1(Taps:end)),title('NavMod0');
 ax3=subplot(4,1,3);
 plot(fdat.temp(Taps:end)),title('Temp');
 ax(4)=subplot(4,1,4);
 plot(fdat.pressure(Taps:end)),title('Pressure');    
 linkaxes([ax1 ax2 ax3],'x');

 fvmon=2*vmon(240,dat.grv);
 Mvmon=mean(fvmon);
 fprintf('\n'); 
 fprintf('mean  VMON %f \n',Mvmon); 
 
  pause;
 close all
 
 %  MakeLines
%  CalcGridRepeats
     