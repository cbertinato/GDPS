% Readfiles in AT1M file format.m
% Read ATM1 format data files
% This script concatenates more that one file
% By Daniel Aliod
% Broomfield August, April 2014

% 

clc;
clear;
close all;
sampling=10;
Per=1/sampling;

% --------------------------------------------------
%  Calculate the filter coefficients
filtertime=150;

 filterlength=filtertime/2;    % filter length =filtertime/2 for fiffif filtering
 Taps=2*filterlength*sampling; % 
 B = fir1(Taps,1/Taps,blackman(Taps+1));
 % filter for timming
 tTap=20*sampling;
 Bt = fir1(tTap,1/tTap,blackman(tTap+1));
 
 % filter for cross correlation monitor cross correlation
 ccTap=30*sampling; % 60 sec filter
 Bcc = fir1(ccTap,1/ccTap,blackman(ccTap+1));
  gravoffset=-979760 % Meter gravity offset
 % gravoffset=0;

 sensortime=3600+1600-16-45; % 1800 here the number obtained in Checktimming test (1.72 second set)
%  sensortime=-5;
 % correct for nown absolute calibration errors
 kfactor=1;
 
% init the env data structure

dat.grv = [];
dat.laccel = [];
dat.xaccel =[];
dat.beam=[];

dat.temp =[];
dat.status=[];

dat.pressure =[];
dat.Etemp=[];

dat.GPSWeek=[];
dat.WeekSeconds=[];

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

in=ReadAT1A(fname);
fprintf('Readed file %s \n',fname); 

% extact time info
 
CC = inputdlg('Add more files?','Load files',1,{'N'});
Morefiles = char(CC);


dat.grv = [dat.grv;in.gravity];
dat.laccel = [dat.laccel;in.long];
dat.xaccel =[dat.xaccel;in.cross];
dat.beam=[dat.beam;in.beam];

dat.temp =[dat.temp;in.temp];
dat.status=[dat.status;in.status];
dat.pressure =[dat.pressure;in.pressure];
dat.Etemp=[dat.Etemp;in.Etemp];


dat.GPSWeek=[dat.GPSWeek;in.GPSweek];
dat.WeekSeconds=[dat.WeekSeconds;in.Weekseconds];
end;  



% Generate Long and cross accelerations from on board 
% real time GPS or INS for performance calculations or marine use
% when a good quality real time navegation is provided in the GPS input

% Regenerate week seconds
dtsec=[0:0.1:length(dat.grv)*0.1];
dtsec=dtsec(1:end-1);
dtsec=dtsec';
dat.WeekSeconds=dat.WeekSeconds(1)+dtsec;



 
  % all this velocities and accelerations are used for simulation
  % and verification pourposes
  % **************************************************************    
    
% metertime=datenum(dat.Y,dat.M,dat.D,dat.h,dat.m,dat.s)*24*3600+sensortime; % seconds
metertime=GPStimetoMLT(dat.GPSWeek,dat.WeekSeconds)*24*3600+sensortime; % seconds;
numtimetide=metertime/24/3600;
startdata=metertime(1);
enddata=metertime(end);

if 1==1
interval=diff(metertime);
Gaps=find(abs(interval) > Per+0.02);
 j=filtfilt(B,1,dat.grv);
plot(j);
           
         [pos,g] = ginput(2);
          x=round(pos(1));
          y=round(pos(2));
        
       
        dat.grv =dat.grv(x:y);
        dat.laccel =dat.laccel(x:y);
        dat.xaccel =dat.xaccel(x:y);
        dat.beam=dat.beam(x:y);
        dat.temp =dat.temp(x:y);
        dat.status=dat.status(x:y);
       
        dat.pressure =dat.pressure(x:y);
        dat.Etemp=dat.Etemp(x:y);
        
        dat.GPSWeek=dat.GPSWeek(x:y);
        dat.WeekSeconds=dat.WeekSeconds(x:y);
        
        
     
       
        numtimetide=numtimetide(x:y);
        startdata=metertime(1);
        enddata=metertime(end);   
        
end               
       
            
   % filter before plotting
 % fgpsacc=filter(B,1,gpsacc);
 
  fgrav=kfactor*filtfilt(B,1,dat.grv)-10000;     % meter  gravity
  
  fdat.laccel=filtfilt(B,1,dat.laccel);
  fdat.xaccel=filtfilt(B,1,dat.xaccel);
  fdat.beam=filtfilt(B,1,dat.beam);
    fdat.temp=filtfilt(B,1,dat.temp);
     fdat.pressure=filtfilt(B,1,dat.pressure);
   fdat.Etemp=filtfilt(B,1,dat.Etemp);
   fdat.time=filtfilt(B,1,metertime);
   
    
    
  %  fccgrav=filtfilt(Bcc,1,dat.grv);     % meter  gravity filtered for cross correlation
  %  fdat.cve=filtfilt(Bcc,1,dat.ve);
  %  fdat.cvcc=filtfilt(Bcc,1,dat.vcc);
  %  fdat.cal=filtfilt(Bcc,1,dat.al);
  %  fdat.cax=filtfilt(Bcc,1,dat.ax);
    
   
    
    % new monitors
 %   fbx=filtfilt(B,1,bx);
 %   cbx=filtfilt(Bcc,1,bx);
 %   fal2=filtfilt(B,1,al2);
 %   cal2=filtfilt(Bcc,1,al2);
 %   fax2=filtfilt(B,1,ax2);
 %   cax2=filtfilt(Bcc,1,ax2);
 %   fx2=filtfilt(B,1,x2);
 %   cx2=filtfilt(Bcc,1,x2);
 %   fl2=filtfilt(B,1,l2);
 %   cl2=filtfilt(Bcc,1,l2);
    



 % aux filtering for timming syncronitztion  
 

% tgravity=dat.grv+P(1)*dat.ve+P(2)*dat.vcc+P(3)*dat.al+P(4)*dat.ax+P(5)*bx+P(6)*al2+P(7)*ax2+P(8)*l2+P(9)*x2; 

ftiming_Meter=filtfilt(Bt,1,dat.grv); % 
tlongacc=filtfilt(Bt,1,dat.laccel); % 

fGravity=fgrav+gravoffset;
% CorrGrav=fGravity+P(1)*fdat.ve+P(2)*fdat.vcc+P(3)*fdat.al+P(4)*fdat.ax+P(5)*fbx+P(6)*fal2+P(7)*fax2+P(8)*fl2+P(9)*fx2;
  

% decode STATUS bits
 clamp=bitget(dat.status,1);        % Meter is clamped
 unclamp=bitget(dat.status,2);      % Meter is unclamp    
 GPSsync=bitget(dat.status,3);      % Meter data time in synv with GPS time        
 feedback=bitget(dat.status,4);     % feedback ON
 R1=bitget(dat.status,5);           % Set feedback range
 R2=bitget(dat.status,6);           % Set feedback range
 ADlock=bitget(dat.status,7);       % AD PLL lock to 1pps
 Rcvd=bitget(dat.status,8);         % serial command aknoledge
 NavMod1=bitget(dat.status,9);      %
 NavMod2=bitget(dat.status,10);     % 
 Platform=bitget(dat.status,11);    % Platform timeout
 MCom=bitget(dat.status,12);        % Meter RSR32 comunication error
 GPSin=bitget(dat.status,13);       % Receiving valid GPS data     



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
 plot(fdat.xaccel(Taps:end)),title('QCgravity');    
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


 
  pause;
 close all
 
 %  MakeLines
%  CalcGridRepeats
     