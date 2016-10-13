% Readfiles in AT1M file format.m
% Read ATM1 format data files
% This script concatenates more that one file
% By Daniel Aliod
% Broomfield August, April 2014

% 

clc;
clear;
close all;
sampling=1;
Per=1/sampling;

% --------------------------------------------------
%  Calculate the filter coefficients
 filterlength=150;    % filter length for data
 Taps=2*filterlength; % 
 B = fir1(Taps,1/Taps,blackman(Taps+1));
 % filter for timming
 tTap=20;
 Bt = fir1(tTap,1/tTap,blackman(tTap+1));
  
 % filter for cross correlation monitor cross correlation
 ccTap=240; % 60 sec filter
 Bcc = fir1(ccTap,1/ccTap,blackman(ccTap+1));
  %  gravoffset=979930 % Meter gravity offset
 gravoffset=0;

 sensortime=-5; % write here the number obtained in Checktimming test (1.72 second set)
%  sensortime=-5;
 % correct for nown absolute calibration errors
 
% kfactor= 0.984048371556240-0.000322432828232;  %for Vantest data AT1M3 29/04/2015
% kfactor=1-0.00031;
  kfactor=1;
 
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

% startdata= 6.360487974630000e+10; % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! jus to overwrite

interval=diff(metertime);
Gaps=find(abs(interval) > Per+0.05);
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
        Gaps=find(abs(interval) > Per+0.05);
        if (~isempty(Gaps))
        uiwait(msgbox('Data gaps detected continue?','Message','none'));
        plot(interval);
        
        end
        
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
 
  fgrav=kfactor*filter(B,1,dat.grv)-driftcorr';     % meter  gravity
  
  fdat.laccel=filter(B,1,dat.laccel);
  fdat.xaccel=filter(B,1,dat.xaccel);
  fdat.beam=filter(B,1,dat.beam);
    fdat.temp=filter(B,1,dat.temp);
     fdat.pressure=filter(B,1,dat.pressure);
   fdat.Etemp=filter(B,1,dat.Etemp);
    fdat.ve=filter(B,1,dat.ve);
      fdat.vcc=filter(B,1,dat.vcc);
     fdat.al=filter(B,1,dat.al);
     fdat.ax=filter(B,1,dat.ax);
    fdat.time=filter(B,1,metertime);
    fdat.lat=filter(B,1,dat.lat);
    fdat.long=filter(B,1,dat.long);
    fdat.speed=filter(B,1,dat.speed);
    fdat.course=filter(B,1,dat.course);
    
    fccgrav=filter(Bcc,1,dat.grv);     % meter  gravity filtered for cross correlation
    fdat.cve=filter(Bcc,1,dat.ve);
    fdat.cvcc=filter(Bcc,1,dat.vcc);
    fdat.cal=filter(Bcc,1,dat.al);
    fdat.cax=filter(Bcc,1,dat.ax);
    
   
    
    % new monitors
    fbx=filter(B,1,bx);
    cbx=filter(Bcc,1,bx);
    fal2=filter(B,1,al2);
    cal2=filter(Bcc,1,al2);
    fax2=filter(B,1,ax2);
    cax2=filter(Bcc,1,ax2);
    fx2=filter(B,1,x2);
    cx2=filter(Bcc,1,x2);
    fl2=filter(B,1,l2);
    cl2=filter(Bcc,1,l2);
    
    fshift=Taps/2+1;
    fccshift=ccTap/2+1;
    
    
    fbx=fbx(fshift:end);
    cbx=cbx(fccshift:end);
    fal2=fal2(fshift:end);
    cal2=cal2(fccshift:end);
     fax2=fax2(fshift:end);
    cax2=cax2(fccshift:end);
     fx2=fx2(fshift:end);
    cx2=cx2(fccshift:end);
    fl2=fl2(fshift:end);
    cl2=cl2(fccshift:end);
    
% eliminating transient and timeshifts
fgrav=fgrav(fshift:end);


fdat.laccel=fdat.laccel(fshift:end);
fdat.xaccel=fdat.xaccel(fshift:end);
fdat.beam=fdat.beam(fshift:end);
fdat.temp=fdat.temp(fshift:end);
fdat.pressure=fdat.pressure(fshift:end);
fdat.Etemp=fdat.Etemp(fshift:end);
fdat.ve=fdat.ve(fshift:end);
fdat.vcc=fdat.vcc(fshift:end);
fdat.al=fdat.al(fshift:end);
fdat.ax=fdat.ax(fshift:end);

fccgrav=fccgrav(fccshift:end);
fdat.cve=fdat.cve(fccshift:end);
fdat.cvcc=fdat.cvcc(fccshift:end);
fdat.cal=fdat.cal(fccshift:end);
fdat.cax=fdat.cax(fccshift:end);

fdat.lat=fdat.lat(fshift:end);
fdat.long=fdat.long(fshift:end);
fdat.speed=fdat.speed(fshift:end);
fdat.course=fdat.course(fshift:end);

 % aux filtering for timming syncronitztion  
 

% tgravity=dat.grv+P(1)*dat.ve+P(2)*dat.vcc+P(3)*dat.al+P(4)*dat.ax+P(5)*bx+P(6)*al2+P(7)*ax2+P(8)*l2+P(9)*x2; 

ftiming_Meter=filter(Bt,1,dat.grv); % 
ftiming_Meter=ftiming_Meter(tTap/2+1:end);


tlongacc=filter(Bt,1,dat.laccel); % 
tlongacc=tlongacc(tTap/2:end);
dat.QCgrav=dat.QCgrav(Taps/2:end);
fGravity=fgrav-gravoffset;
% CorrGrav=fGravity+P(1)*fdat.ve+P(2)*fdat.vcc+P(3)*fdat.al+P(4)*fdat.ax+P(5)*fbx+P(6)*fal2+P(7)*fax2+P(8)*fl2+P(9)*fx2;
  

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



scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('Data');
 ax1=subplot(4,1,1);
 plot(fGravity(Taps:end)),title('Gravity');
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
 plot(fGravity(Taps:end)),title('Gravity');
 ax2=subplot(4,1,2);
 plot(fdat.laccel(Taps:end)),title('Long');
 ax3=subplot(4,1,3);
 plot(fdat.xaccel(Taps:end)),title('Cross');
 ax(4)=subplot(4,1,4);
 plot(unclamp(Taps:end)),title('Unclamp');    
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
 plot(fGravity(Taps:end)),title('Gravity');
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
     