% ReadfilesAT1A2.m
% Readfiles in AT1A2 file format
% This script can concatenate more that one file
% By Daniel Aliod
% Broomfield August, April 2014
% Modified  October 2015

clc;
clear;
close all;
Meteroffset=10000;

% load congiguration 
Levelcorr=0;
filtertime=100; % desired filter time in seconds half
gravoffset=0;
sensortime=0; % write here the number obtained in Checktimming test 

% default values

sampling=10;    % The typical sampling for Airborne data is 10 sample/s
Per=1/sampling;
Prefiltcorr=0;  %  Analog filter compensation
filtertype=0; % if type=0 Blackman, if type=1 Gausian

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

offset=str2double(Tieg)-kfactor*str2double(PreStillReading);


fprintf('\n');
fprintf('Meter Offset in Tie %f \n',offset);

%  Calculate the FIR filter coefficients

 filterlength=filtertime;    % 
 Taps=2*filterlength*sampling; % 
 B= fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 100 sec sec data
 
 % filter for timming procedures
 Taps=2*1*sampling; % 1 second data  
 B1s = fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 1 sec data

 tTap=20;
 Bt = fir1(tTap,1/tTap,blackman(tTap+1));
 
 % filter for cross correlation monitor cross correlation
 ccTap=240*sampling; % 6
 Bcc = fir1(ccTap,1/ccTap,blackman(ccTap+1));
 %  gravoffset=979930 % Meter gravity offset
  


 
 gpsleap=17;  % June 30, 2015
 %gpsleap=16; % June 30, 2012
 %gpsleap=15; % December 31, 2008
 %gpsleap=14; % December 31, 2005
 %gpsleap=13; % December 31, 1998
 %gpsleap=12; % June 30, 1997


 
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


 Morefiles='Y';
 while Morefiles=='Y'
 % do things

 % do things
  [file p] = uigetfile('p\*.*','Load DGS data file file');
  fname=[p file] ;
%  save oldpath  p;
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

% dat.grv=dat.grv-Meteroffset;
% fix not

% fixtime=6*3600+12;
fixtime=0;

% metertime=datenum(dat.Y,dat.M,dat.D,dat.h,dat.m,dat.s)*24*3600+sensortime;    % seconds
metertime=GPStimetoMLT(dat.GPSWeek,dat.WeekSeconds)*24*3600+sensortime-gpsleap+fixtime; % seconds

 datafiletime=datestr(GPStimetoMLT(dat.GPSWeek(1),dat.WeekSeconds(1)));
  fprintf('\n');
   fprintf('Data start %s  \n',datafiletime);   
   datafiletime=datestr(GPStimetoMLT(dat.GPSWeek(end),dat.WeekSeconds(end)));
  fprintf('\n');
   fprintf('Data end %s  \n',datafiletime);   

numtimetide=metertime/24/3600;
startdata=metertime(1);
enddata=metertime(end);
interval=diff(metertime);
Gaps=find(abs(interval) > Per*1.9);

if (~isempty(Gaps))
uiwait(msgbox('Data gaps detected continue?','Message','none'));
plot(interval);

CC = inputdlg('Crop data or fill the gaps? C F','Format',1,{'C'});
 CC = char(CC);
        if CC=='C' 
            
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
            numtimetide=numtimetide(x:y);
            metertime=metertime(x:y);
            
            startdata=metertime(1);
            enddata=metertime(end);   
        
            % check for more Gaps after the crop
        
            interval=diff(metertime);
            Gaps=find(abs(interval) > Per*1.9);
            
                 if (~isempty(Gaps))
                    uiwait(msgbox('Data gaps detected continue?','Message','none'));
                     plot(interval);
                    pause
                    dt = mode(interval);             %average periode
                    
                    nom_end=round((metertime(end)-metertime(1))/dt + 1);  % number of samples tat should be acording to time
                    
                    t1 =metertime(1);
                    
                    timeind = round((metertime - t1)/dt + 1); % time real of sample
                    
                    tcorrmeter = linspace(metertime(1),metertime(end),nom_end)'; % new generated time vector
                    
                    miss=find(interval > dt+0.06);
                     
                     dat.grv=MissNaNs(dat.grv,timeind,nom_end); 
                     dat.laccel=MissNaNs( dat.laccel,timeind,nom_end); 
                    dat.xaccel=MissNaNs(dat.xaccel,timeind,nom_end); 
                    dat.beam=MissNaNs( dat.beam,timeind,nom_end); 
                    dat.temp=MissNaNs(dat.temp,timeind,nom_end); 
                    dat.status=MissNaNs(dat.status,timeind,nom_end); 
            %        dat.checksum=MissNaNs( dat.checksum,timeind,nom_end); 
                    dat.pressure=MissNaNs(dat.pressure,timeind,nom_end); 
                    dat.Etemp=MissNaNs(dat.Etemp,timeind,nom_end); 
      
                    dat.grv=FillDataGaps(dat.grv);  
                    dat.xaccel=FillDataGaps( dat.xaccel);  
                    dat.laccel=FillDataGaps(dat.laccel);  
                    dat.beam=FillDataGaps(dat.beam);  
                    dat.temp=FillDataGaps(dat.temp);  
                    dat.pressure=FillDataGaps(dat.pressure);  
                    dat.Etemp=FillDataGaps(dat.Etemp);   
          
                    mynan=isnan(dat.status);
                    dat.status(mynan)=0;
        
                    %  dat.lat=FillDataGaps(dat.lat);  
                    %  dat.long=FillDataGaps(dat.long);  
       
                    metertime= tcorrmeter;
                    startdata=metertime(1);
                    enddata=metertime(end);   
                    
                    length(dat.grv)  
                    length(tcorrmeter)
                    
                 end % end of fill the gaps after croping
       
        else % if not initial crop only fill the gaps
         
         if(1==1)   
             
         dt = mode(interval);
         nom_end=round((metertime(end)-metertime(1))/dt + 1);
         t1 =metertime(1);
         timeind = round((metertime - t1)/dt + 1);
         tcorrmeter = linspace(metertime(1),metertime(end),nom_end)'; 
        
         
         miss=find(interval > dt+0.1);
            
         dat.grv=MissNaNs( dat.grv,timeind,nom_end); 
         dat.laccel=MissNaNs( dat.laccel,timeind,nom_end); 
         dat.xaccel=MissNaNs(dat.xaccel,timeind,nom_end); 
         dat.beam=MissNaNs( dat.beam,timeind,nom_end); 
         dat.temp=MissNaNs(dat.temp,timeind,nom_end); 
         dat.status=MissNaNs(dat.status,timeind,nom_end); 
        
         dat.pressure=MissNaNs(dat.pressure,timeind,nom_end); 
         dat.Etemp=MissNaNs(dat.Etemp,timeind,nom_end); 
         
       %  dat.lat=MissNaNs(dat.lat,timeind,nom_end); 
       %  dat.long=MissNaNs(dat.long,timeind,nom_end); 
         dat.grv=FillDataGaps( dat.grv); 
         dat.laccel=FillDataGaps( dat.laccel); 
         dat.xaccel=FillDataGaps(dat.xaccel); 
         dat.beam=FillDataGaps( dat.beam); 
         dat.temp=FillDataGaps(dat.temp); 
         
          mynan=isnan(dat.status);
         dat.status(mynan)=0;
        
         dat.pressure=FillDataGaps(dat.pressure); 
         dat.Etemp=FillDataGaps(dat.Etemp); 
        
        % dat.lat=FillDataGaps(dat.lat); 
        % dat.long=FillDataGaps(dat.long); 
      
        metertime= tcorrmeter;
        startdata=metertime(1);
        enddata=metertime(end);   
      end   % end of if 1==1
    end  %of crip or fill  

end % end if there is gaps

driftcorr= linspace(0,drift,length(metertime)); 

% fprintf('start data %f \n',startdata);
% fprintf('end data %f \n',enddata);
% fprintf('total seconds %f \n',enddata-startdata);

% make more monitors
vcc=1000*dat.beam.*dat.laccel;
lc=dat.laccel;     % long acc coupling cross direction
xc=dat.xaccel;     % cross acc coupling

ve=1e-6*(dat.grv).^2;     % ve
al=1e-6*dat.grv.*dat.laccel;
ax=1e-6*dat.grv.*dat.xaccel;
% l2=1e-2*dat.laccel.^2;

% tide=LongmanTidePredictor(dat.long,dat.lat,metertime/24/3600); % calculate tidal effect


% filter before plotting
  
  % apply median filter for fixing communication error
  
  % dat.grv=medfilt1(dat.grv,10); % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ddg=diff(diff(diff(dat.grv)));
  ddg=[0;0;ddg;0;0];
  
  

  % filter the data
  % a=gaussian_filter(metertime,Eotvos,filtertime,3);
  
  if filtertype==0
  fprintf('\n');
  fprintf('FIR blackman filter applayed  \n');
  meterg=filtfilt(B,1,dat.grv)-Meteroffset-driftcorr';         % meter  no offset no Kfactor
  fgrav_plot=kfactor*filtfilt(B,1,dat.grv)-driftcorr'+offset;     % meter  gravity to select the lines
  
  fgrav=kfactor*filtfilt(B1s,1,dat.grv)-driftcorr'+offset;     % meter  gravity 
  fdat.laccel=filtfilt(B1s,1,dat.laccel);
  fdat.laccel_plot=filtfilt(B,1,dat.laccel);
  
  fdat.xaccel=filtfilt(B1s,1,dat.xaccel);
  % fdat.beam=filtfilt(B1s,1,dat.beam);  & we want to see the beam raw
  fdat.beam=dat.beam;
  fdat.temp=filtfilt(B1s,1,dat.temp);
  fdat.pressure=filtfilt(B1s,1,dat.pressure);
  fdat.Etemp=filtfilt(B1s,1,dat.Etemp);
 
      
   % new monitors
    flc=filtfilt(B1s,1,lc);
    fxc=filtfilt(B1s,1,xc);
    fve=filtfilt(B,1,ve);
    fvcc=filtfilt(B1s,1,vcc); 
    fal=filtfilt(B1s,1,al);
    fax=filtfilt(B1s,1,ax);
 

  else
      
   fprintf('\n');
    fprintf('FIR gausian filter  \n');   
    
 %   driftcorr=[0 driftcorr];
   
 GPSsync=bitget(dat.status,3);
 if GPSsync==1 % only if driff corr if time syncronized
  meterg=gaussian_filter(metertime,dat.grv,filtertime,3)-driftcorr;                 % meter  no offset no Kfactor
  fgrav=kfactor*gaussian_filter(metertime,dat.grv,1,3)-driftcorr+offset;            % meter  gravity 
   fgrav_plot=kfactor*gaussian_filter(metertime,dat.grv,filtertime,3)-driftcorr;     % meter  gravity 
  
 else 
 meterg=gaussian_filter(metertime,dat.grv,filtertime,3);         % meter  no offset no Kfactor
 fgrav=kfactor*gaussian_filter(metertime,dat.grv,1,3)+offset;     % meter  gravity 
 fgrav_plot=kfactor*gaussian_filter(metertime,dat.grv,filtertime,3);     % meter  gravity 
     
 end
  
  fdat.laccel=gaussian_filter(metertime,dat.laccel,1,3);
  fdat.laccel_plot=gaussian_filter(metertime,dat.laccel,filtertime,3);
  
  fdat.xaccl=gaussian_filter(metertime,dat.xaccel,1,3);
  fdat.beam=gaussian_filter(metertime,dat.beam,1,3);
  fdat.temp=gaussian_filter(metertime,dat.temp,1,3);
  fdat.pressure=gaussian_filter(metertime,dat.pressure,1,3);
  fdat.Etemp=gaussian_filter(metertime,dat.Etemp,1,3);   
  
  meterg=meterg';
  fgrav=fgrav';
  fdat.laccel=fdat.laccel';
  fdat.xaccel=fdat.xaccl';
  fdat.beam=fdat.beam';
  fdat.temp=fdat.temp';
  fdat.pressure=fdat.pressure';
   fdat.Etemp= fdat.Etemp';
  
   % new monitors
    flc=gaussian_filter(metertime,lc,1,3);
    fxc=gaussian_filter(metertime,xc,1,3);
    fve=gaussian_filter(metertime,ve,1,3);
    fvcc=gaussian_filter(metertime,vcc,1,3); 
    fal=gaussian_filter(metertime,al,1,3);
    fax=gaussian_filter(metertime,ax,1,3);
    
    flc=flc';
     fxc= fxc';
     fve=fve';
     fvcc=fvcc';
     fal=fal';
     fax=fax';
     
 
  end
 
 
 ftiming_Meter=filtfilt(Bt,1,dat.grv); %  
tlongacc=filtfilt(Bt,1,dat.laccel); % 



if monitors_comp==1
fgrav=fgrav+ve_comp*fve+lc_comp*flc+xc_comp*fxc+vcc_comp*fvcc;  
 fprintf('Using CC correction \n'); 
 fprintf('ve=%f \n',ve_comp);
fprintf('vcc=%f \n',vcc_comp);
fprintf('lc=%f \n',lc_comp);
fprintf('xc=%f \n',xc_comp);
end
% CorrGrav=fGravity+P(1)*fdat.ve+P(2)*fdat.vcc+P(3)*fdat.al+P(4)*fdat.ax+P(5)*fbx+P(6)*fal2+P(7)*fax2+P(8)*fl2+P(9)*fx2;


% decode STATUS bits
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
 plot(meterg(Taps:end)),title('Meter Gravity');
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
 plot(fgrav(Taps:end)),title('Full field Gravity');
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
 plot(fgrav(Taps:end)),title('Gravity');
 ax2=subplot(4,1,2);
 plot(NavMod1(Taps:end)),title('NavMod0');
 ax3=subplot(4,1,3);
 plot(fdat.temp(Taps:end)),title('Temp');
 ax(4)=subplot(4,1,4);
 plot(fdat.pressure(Taps:end)),title('Pressure');    
 linkaxes([ax1 ax2 ax3],'x');
 
   scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('Data');
 ax1=subplot(4,1,1);
 plot(NavMod1(Taps:end)),title('Nav Mode0');
 ax2=subplot(4,1,2);
 plot(NavMod2(Taps:end)),title('Nav Mod0');
 ax3=subplot(4,1,3);
 plot(SensCom(Taps:end)),title('Sensror Comunication');
 ax(4)=subplot(4,1,4);
 plot(ADsat(Taps:end)),title('Saturation');    
 linkaxes([ax1 ax2 ax3],'x');
 
 

     