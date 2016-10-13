% ReadGPS2_Airborne.m
% Reads the GPS file from GrafNav export in DGS Air format
 gpsleap=17; % June 30, 2015
 %gpsleap=16; % June 30, 2012
 %gpsleap=15; % December 31, 2008
 %gpsleap=14; % December 31, 2005
 %gpsleap=13; % December 31, 1998
 %gpsleap=12; % June 30, 1997
 
  % Platform Tilt corrections
  
  LeverArm=0;
  
  % distances from gravity meter to antena or source of solution
  X=-1.285; % X+ is to the right
  Y=8.336;  % Y+ is forward
  Z=1.696;  % Z+ is up
 
 [file p] = uigetfile('*.*','Load gps position');
 fname=[p file] ;
 
 switch LeverArm
         
 case 0
 
  [gps_Date,gps_time,gps_lat,gps_long,gps_orthoheight,gps_elipsoidheight,Num_satelites,PDOP] = ...
    textread(fname,['%s %s %f %f %f %f %d %f'],'delimiter',',','headerlines',1);
 case 1
   [gps_Date,gps_time,gps_lat,gps_long,gps_orthoheight,gps_elipsoidheight,Pitch,Roll,Heading,Num_satelites,PDOP] = ...
    textread(fname,['%s %s %f %f %f %f %f %f %f %d %f'],'delimiter',',','headerlines',1);
   % [gps_lat,gps_long,gps_orthoheight,gps_elipsoidheight]=LeverArmComp(gps_lat,gps_long,gps_orthoheight,gps_elipsoidheight,Pitch,Roll,Heading,X,Y,Z);
    [gps_lat,gps_long,gps_orthoheight,gps_elipsoidheight]=LeverArmComp2(gps_lat,gps_long,gps_orthoheight,gps_elipsoidheight,Pitch,Roll,Heading,X,Y,Z);

 end

     gpsstringtime=strcat(gps_Date,gps_time);
    tgps=datenum(gpsstringtime,'mm/dd/yyyyHH:MM:ss.FFF')*24*3600-gpsleap;
    start_gps=tgps(1);
    % detect for Gaps in the GPS data
    interval=diff(tgps);
    interval=interval(2:end-2);    % eliminate the initial transient
    Gaps=find(interval > Per+0.02);
    if (~isempty(Gaps))
    uiwait(msgbox('GPS data gaps detected continue?','Message','none'));
    figure(1),title('Select lines');
    plot(interval),title('Gps data gaps');
    CC = inputdlg('Crop data or fill the gaps? C F','Format',1,{'C'});
        
        CC = char(CC);
        if CC=='C' 
        [pos,g] = ginput(2);
        x=round(pos(1));
        y=round(pos(2));
         close all
    
        gps_Date=gps_Date(x:y);
        gps_time=gps_time(x:y);
        gps_lat=gps_lat(x:y);
        gps_long=gps_long(x:y);
        gps_orthoheight=gps_orthoheight(x:y);
        gps_elipsoidheight=gps_elipsoidheight(x:y);  
        Num_satelites=Num_satelites(x:y);
        PDOP=PDOP(x:y);
        tgps=tgps(x:y);
        start_gps=tgps(1);
        
        % check for Gaps after the crop
         interval=diff(tgps);
        interval=interval(2:end-2);    % eliminate the initial transient
         Gaps=find(interval > Per+0.02);
        if (~isempty(Gaps))
         plot(interval),title('Gps data gaps');
        uiwait(msgbox('GPS data gaps detected continue?','Message','none'));
        
         
        end
        
        % dt = mode(interval); !!!!!!!!!!!!!!!!
         dt=1/sampling;
         nom_end=round((tgps(end)-tgps(1))/dt + 1);
         t1 = tgps(1);
         timeind = round((tgps - t1)/dt + 1);
         tcorrgps = linspace(tgps(1),tgps(end),nom_end)'; 
         miss=find(interval > dt+0.1);
             
        gps_lat=MissNaNs(gps_lat,timeind,nom_end); 
        gps_long=MissNaNs(gps_long,timeind,nom_end); 
        gps_orthoheight=MissNaNs(gps_orthoheight,timeind,nom_end); 
        gps_elipsoidheight=MissNaNs(gps_elipsoidheight,timeind,nom_end);  
        Num_satelites=MissNaNs( Num_satelites,timeind,nom_end); 
        PDOP=MissNaNs(PDOP,timeind,nom_end); 
        
         gps_orthoheight=FillDataGaps(gps_orthoheight);  
         gps_elipsoidheight=FillDataGaps(gps_elipsoidheight);  
         Num_satelites=FillDataGaps(Num_satelites);  
         PDOP=FillDataGaps(PDOP);   
         gps_lat=FillDataGaps(gps_lat);  
         gps_long=FillDataGaps(gps_long);  
           
          tgps= tcorrgps;  
          start_gps=tgps(1);     
        
        
        else
         dt = mode(interval);
         nom_end=round((tgps(end)-tgps(1))/dt + 1);
         t1 = tgps(1);
         timeind = round((tgps - t1)/dt + 1);
         tcorrgps = linspace(tgps(1),tgps(end),nom_end)'; 
         miss=find(interval > dt+0.1);
             
        gps_lat=MissNaNs(gps_lat,timeind,nom_end); 
        gps_long=MissNaNs(gps_long,timeind,nom_end); 
        gps_orthoheight=MissNaNs(gps_orthoheight,timeind,nom_end); 
        gps_elipsoidheight=MissNaNs(gps_elipsoidheight,timeind,nom_end);  
        Num_satelites=MissNaNs( Num_satelites,timeind,nom_end); 
        PDOP=MissNaNs(PDOP,timeind,nom_end); 
        
         gps_orthoheight=FillDataGaps(gps_orthoheight);  
         gps_elipsoidheight=FillDataGaps(gps_elipsoidheight);  
         Num_satelites=FillDataGaps(Num_satelites);  
         PDOP=FillDataGaps(PDOP);   
         gps_lat=FillDataGaps(gps_lat);  
         gps_long=FillDataGaps(gps_long);  
           
          tgps= tcorrgps;  
          start_gps=tgps(1);     
            
            
        end
    end  
        
  if 1==1  % eliminate flip in long  
       len=length(gps_long);
  
    for t=1:1:len
        
          if (gps_long(t)<0) 
           long_noflip(t)=gps_long(t)+360;
          else
            long_noflip(t)=gps_long(t);  
          end
          
    end  
    gps_long=long_noflip'; 
    
  end    
     
  
  
   
      if (Prefiltcorr==1)
        fprintf('Applaying pre filter \n');    
            
        load MeterFilterModel;
        gps_lat=filter(meterfilt,1,gps_lat);
        gps_long=filter(meterfilt,1,gps_long);
        gps_orthoheight=filter(meterfilt,1,gps_orthoheight);
        gps_elipsoidheight=filter(meterfilt,1, gps_elipsoidheight);
     end
            
      % make GPS calculations
    
     tide=LongmanTidePredictor(gps_long,gps_lat,tgps/24/3600); % calculate correction
     
     
     % caculate vertical acceleration
    gpsvel=convn(gps_elipsoidheight,tay10','same');
    gpsacc=1e5*convn(gpsvel,tay10','same')*sampling^2;
    
    % long_noflip= long_noflip';
     
    % calculate North and E velocities
    [gps_Evel,gps_Nvel] = LatLon2VeVn(gps_lat,gps_long);
    gps_Evel=sampling*gps_Evel;
    gps_Nvel=sampling*gps_Nvel;
    
    
   
    % calculate North and East accelerations
    gps_Eacc=1e5*sampling*convn(gps_Evel,tay10','same');
    gps_Nacc=1e5*sampling*convn(gps_Nvel,tay10','same');
    
   % Latcorr=-WGS84(gps_lat)-FAC2ord(deg2rad(gps_lat),gps_orthoheight);
   % Latcorr=calc_facorrection(gps_lat,gps_orthoheight); 
    Latcorr=-WGS84(gps_lat)-FAC2ord(deg2rad(gps_lat),gps_elipsoidheight);
    Eotvos=AbsEotvosCorrAir(gps_lat,gps_elipsoidheight,gps_Evel,gps_Nvel);
    Eotvos_full=calc_eotvos_full(gps_lat,gps_long,gps_elipsoidheight,10);
    Eotvos_full=Eotvos_full'; % Eotvos full includes eotvos and vertical acceleration
     
    GPS_Corrections=Eotvos_full+tide;        %GPS corrections Eotvos + GPS vertical acceleration
         
         % LevelError=zeros(1,length(GPS_Corrections));
         % LevelError=LevelError';
         
         [crse,vel] =VeVn2CseVel(gps_Evel,gps_Nvel);
         [gpsacccross,gpsacclong]=ENacc2Body(crse,gps_Eacc,gps_Nacc);  
         gpsacccross=-gpsacccross;
         
         %  Tilt_simulation;
        ON=1; % turn on and off accelerometer
        % [Longa,Crossa]=Platform_controller_simulation(ON*gpsacclong,ON*gpsacccross,-Latcorr,sampling);  
        % upvecs=CalcPlatUpVec(Crossa,-Longa);
          upvecs = PlatModel(1/sampling,-Latcorr,gpsacccross,gpsacclong,0,240,0.7071,240,0.7071); % was 240
          
        %  GPSinPlat = GPS2MeterAxis(0*GPS_Corrections,gpsacclong, gpsacc, upvecs); %
          IGFinPlat =-Latcorr .*upvecs(3,:)'; % calculate the Lattitude correction on platform
          CrossInPlat=gpsacccross.*upvecs(2,:)';
          LongInPlat=gpsacclong.*upvecs(1,:)';
          
          % LevelError=-Latcorr-IGFinPlat;
           
          LevelError=-Latcorr-IGFinPlat-LongInPlat+CrossInPlat;
         
    
   
     % --------------------------------------------------------------------
    
 
     
%  egm=egm08_interp(gps_lat,longitude0_360,gps_elipsoidheight);

%    egm=egm08_interp(gps_lat,gps_long,gps_elipsoidheight);
   
   
   
    
  % filter before plotting
  
  
  if filtertype==0
  
  fgpsacc=filtfilt(B1s,1,gpsacc);
  fgpsacc_plot=filtfilt(B,1,gpsacc);
  
 % fGPStotalacc_OnSensor=filtfilt(B,1,GPStotalacc_OnSensor); % all GPS corrections
  fgps_Evel=filtfilt(B1s,1,gps_Evel);
  fgps_Nvel=filtfilt(B1s,1,gps_Nvel);
  ftide=filtfilt(B1s,1,tide);
  egm(1:10)=0;
%   fegm=filtfilt(B1s,1,egm);
  
  gpsacclong(1:10)=0;
 gpsacclong(end-10:end)=0;
  fgpsacclong=filtfilt(B1s,1, gpsacclong);
  gpsacccross(1:10)=0;
 gpsacccross(end-10:end)=0;
  fgpsacccross=filtfilt(B1s,1,gpsacccross);
 % fLongTilt=filtfilt(B,1,LongTilt);
 % fCrossTilt=filtfilt(B,1,CrossTilt);
 
 LevelError(1:10)=0;
 LevelError(end-10:end)=0;
 fLevelError=filtfilt(B1s,1,LevelError);
 % plot(fLevelError);
 
 LongInPlat(1:10)=0;
 LongInPlat(end-10:end)=0;
 fLongInPlat =filtfilt(B1s,1,LongInPlat);
 
  CrossInPlat(1:10)=0;
CrossInPlat(end-10:end)=0;
 fCrossInPlat=filtfilt(B1s,1,CrossInPlat);
 
 
  fgps_lat=filtfilt(B1s,1,gps_lat);
  fgps_long=filtfilt(B1s,1,gps_long);
  fgps_orthoheight=filtfilt(B1s,1,gps_orthoheight);
  fgps_elipsoidheight=filtfilt(B1s,1,gps_elipsoidheight);
  Eotvos(1:10)=0;
  Eotvos(end-10:end)=0;
  fEotvos=filtfilt(B1s,1,Eotvos);
  fEotvos_plot=filtfilt(B,1,Eotvos);
  
  fLatcorr=filtfilt(B1s,1,Latcorr);
  
  GPS_Corrections(1:10)=0;
  GPS_Corrections(end-10:end)=0;
  fGPS_Corrections=filtfilt(B1s,1,GPS_Corrections);
  
 TimingGPS=-gpsacc+Eotvos;
 fTimingGPS=filtfilt(Bt,1,TimingGPS); %
 
  else
      
   fgpsacc=gaussian_filter(tgps,gpsacc,1,3);
   fgpsacc_plot=gaussian_filter(tgps,gpsacc,filtertime,3);
   
   fgpsacc=fgpsacc';
 % fGPStotalacc_OnSensor=gaussian_filter(metertime,1,GPStotalacc_OnSensor); % all GPS corrections
  fgps_Evel=gaussian_filter(tgps,gps_Evel,1,3);
  fgps_Evel= fgps_Evel';
   
  fgps_Nvel=gaussian_filter(tgps,gps_Nvel,1,3);
  fgps_Nvel=fgps_Nvel';
  
  ftide=gaussian_filter(tgps,tide,1,3);
  ftide=ftide';
  
  egm(1:10)=0;
%   fegm=gaussian_filter(tgps,egm,1,3);
%   fegm=fegm';
  gpsacclong(1:10)=0;
 gpsacclong(end-10:end)=0;
  fgpsacclong=gaussian_filter(tgps,gpsacclong,1,3);
  fgpsacclong=fgpsacclong';
  gpsacccross(1:10)=0;
 gpsacccross(end-10:end)=0;
  fgpsacccross=gaussian_filter(tgps,gpsacccross,1,3);
  fgpsacccross=fgpsacccross';
  
 % fLongTilt=gaussian_filter(metertime,1,LongTilt);
 % fCrossTilt=gaussian_filter(metertime,1,CrossTilt);
 
 LevelError(1:10)=0;
 LevelError(end-10:end)=0;
  fLevelError=gaussian_filter(tgps,LevelError,1,3);
 fLevelError= fLevelError';
 % plot(fLevelError);
 
  fgps_lat=gaussian_filter(tgps,gps_lat,1,3);
  fgps_lat=fgps_lat';
  fgps_long=gaussian_filter(tgps,gps_long,1,3);
  fgps_long=fgps_long';
  fgps_orthoheight=gaussian_filter(tgps,gps_orthoheight,1,3);
  fgps_orthoheight=fgps_orthoheight';
  fgps_elipsoidheight=gaussian_filter(tgps,gps_elipsoidheight,1,3);
  fgps_elipsoidheight=fgps_elipsoidheight';
  Eotvos(1:10)=0;
  Eotvos(end-10:end)=0;
  
  fEotvos=gaussian_filter(tgps,Eotvos,1,3);
  fEotvos_plot=gaussian_filter(tgps,Eotvos,filtertime,3);
  
  fEotvos=fEotvos';
  
  fLatcorr=gaussian_filter(tgps,Latcorr,1,3);
  fLatcorr=fLatcorr';
  GPS_Corrections(1:10)=0;
  GPS_Corrections(end-10:end)=0;
  fGPS_Corrections=gaussian_filter(tgps,GPS_Corrections,1,3);
  fGPS_Corrections=fGPS_Corrections';
  
 TimingGPS=-gpsacc+Eotvos;
 fTimingGPS=filtfilt(Bt,1,TimingGPS); %    
      
      
  end
 
 scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('GPS Raw Data');
 ax1=subplot(4,1,1);
 plot(gpsacc(Taps:end)),title('GPS vertical acc');
 ax2=subplot(4,1,2);
 plot(Eotvos(Taps:end)),title('Eotvos');
 ax3=subplot(4,1,3);
 plot( GPS_Corrections(Taps:end)),title('GPS corrections');
 ax(4)=subplot(4,1,4);
 plot(gps_elipsoidheight(Taps:end)),title('Elipsoidal high');    
 linkaxes([ax1 ax2 ax3],'x');
pause
     
 close all    
    

    
    