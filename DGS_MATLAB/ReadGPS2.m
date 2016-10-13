
% Read GPS_DGS.m
%

 gpsleap=17; % June 30, 2015
 %gpsleap=16; % June 30, 2012
 %gpsleap=15; % December 31, 2008
 %gpsleap=14; % December 31, 2005
 %gpsleap=13; % December 31, 1998
 %gpsleap=12; % June 30, 1997
 [file p] = uigetfile('*.*','Load gps position');
 fname=[p file] ;
 
  [gps_Date,gps_time,gps_lat,gps_long,gps_orthoheight,gps_elipsoidheight,Num_satelites,PDOP] = ...
    textread(fname,['%s %s %f %f %f %f %d %f'],'delimiter',',','headerlines',1);
    gpsstringtime=strcat(gps_Date,gps_time);
    tgps=datenum(gpsstringtime,'mm/dd/yyyyHH:MM:ss.FFF')*24*3600-gpsleap;
    start_gps=tgps(1);
    % detect for Gaps in the GPS data
    interval=diff(tgps);
    interval=interval(2:end-2);    % eliminate the initial transient
    Gaps=find(interval > Per+0.01);
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
     
        else
            
         dt = mode(interval);
         nom_end=round((tgps(end)-tgps(1))/dt + 1);
         t1 = tgps(1);
         timeind = round((tgps - t1)/dt + 1);
         tcorrgps = linspace(tgps(1),tgps(end),nom_end)'; 
         miss=find(interval > dt+0.1);
         
       % gps_Date=MissNaNs(gps_Date,timeind,nom_end); 
       % gps_time=MissNaNs(gps_time,timeind,nom_end); 
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
    
      
        if (Prefiltcorr==1)
        load MeterFilterModel;
        
        x1=resample(gps_lat,10,1);
         x2=resample(gps_long,10,1);
          x3=resample(gps_orthoheight,10,1);
           x4=resample(gps_elipsoidheight,10,1);
        
        
        gps_lat=filter(meterfilt,1,x1);
        gps_long=filter(meterfilt,1,x2);
        gps_orthoheight=filter(meterfilt,1,x3);
        gps_elipsoidheight=filter(meterfilt,1,x4);
        
        
       gps_lat=resample(gps_lat,1,10);
       gps_long=resample(gps_long,1,10);
       gps_orthoheight=resample(gps_orthoheight,1,10);
       gps_elipsoidheight=resample(gps_elipsoidheight,1,10);
        
      % gps_lat=gps_lat(20:end-20);
      % gps_long=gps_long(20:end-20);
      % gps_orthoheight=gps_orthoheight(20:end-20);
      % gps_elipsoidheight=gps_elipsoidheight(20:end-20);
      % tgps=tgps(20:end-20);
        
        end
    
     % make GPS calculations
    
     tide=LongmanTidePredictor(gps_long,gps_lat,tgps/24/3600); % calculate tidal effect
     
     
      % caculate vertical acceleration
    gpsvel=convn(gps_elipsoidheight,tay10','same');
    gpsacc=1e5*convn(gpsvel,tay10','same')*sampling^2;
    
    % calculate North and E velocities
    [gps_Evel,gps_Nvel] = LatLon2VeVn( gps_lat, gps_long);
    gps_Evel=sampling*gps_Evel;
    gps_Nvel=sampling*gps_Nvel;
    % calculate North and East accelerations
    gps_Eacc=1e5*sampling*convn(gps_Evel,tay10','same');
    gps_Nacc=1e5*sampling*convn(gps_Nvel,tay10','same');
    
  %  Latcorr=-WGS84(gps_lat)-FAC2ord(deg2rad(gps_lat),gps_orthoheight);
    Latcorr=-WGS84(gps_lat)-FAC2ord(deg2rad(gps_lat),gps_elipsoidheight);
    
  %  Latcorr=calc_facorrection(gps_lat,gps_elipsoidheight); 
   
    Eotvos=AbsEotvosCorrAir(gps_lat,gps_elipsoidheight,gps_Evel,gps_Nvel); 
   % Eotvos=AbEotvosCorrGrnd(gps_Evel,gps_Nvel,gps_elipsoidheight,gps_lat);
    
    % Platform Tilt corrections
     Plat_mode=1;
 
     switch Plat_mode
     case 0
         % no platform correction apliyed
         GPS_Corrections=Eotvos-gpsacc+Latcorr;
         LevelError=zeros(1,length(GPS_Corrections));
         GPS_Corrections=Eotvos-gpsacc+Latcorr;
         [crse,vel] =VeVn2CseVel(gps_Evel,gps_Nvel);
          
         [gpsacccross, gpsacclong]=ENacc2Body(crse,gps_Eacc,gps_Nacc);  
    
     case 1     
         
          GPS_Corrections=Eotvos-gpsacc+Latcorr;
          [crse,vel] =VeVn2CseVel(gps_Evel,gps_Nvel);
          [gpsacccross, gpsacclong]=ENacc2Body(crse,gps_Eacc,gps_Nacc);  
        %  Tilt_simulation;
          ON=1; % turn on and off accelerometer
         [Longa,Crossa]=Platform_controller_simulation(-ON*gpsacclong,ON*gpsacccross,-Latcorr,sampling);  
         upvecs=CalcPlatUpVec(Crossa,-Longa);
         upvecdaniel=upvecs;
         
          upvecs1 = PlatModel(1/sampling,-Latcorr,gpsacccross,gpsacclong,0,240,0.7071,240,0.7071); % was 240
          upvecs= upvecs1;
         
         save vrtical upvecs
         
         IGFinPlat =Latcorr .*upvecs(3,:)';
         GPSinPlat = GPS2MeterAxis(gpsacccross,gpsacclong, gpsacc, upvecs);
         GPStotalacc_OnSensor=-GPSinPlat+IGFinPlat+Eotvos;
         LevelError=GPStotalacc_OnSensor-GPS_Corrections;
         GPS_Corrections=GPStotalacc_OnSensor;
         
       % Longa=upvecs(1,:);
       % Crossa=upvecs(2,:);
        Tilt= Longa;
      % now calculate the simulated meter accelerometer outputs
        % for model tunning 
        
      %  simlong=-gpsacclong.*cos(Longa)+GPS_Corrections.*sin(Longa);
      %  simcross=-gpsacccross.*cos(Crossa)+GPS_Corrections.*sin(Crossa);
      % simlong=-gpsacclong.*cos(Longa);
      % simcross=-gpsacccross.*cos(Crossa);
    
 end 
     % --------------------------------------------------------------------
    
    
    
  % filter before plotting
  fgpsacc=filtfilt(B,1,gpsacc);
  
  % fGPStotalacc_OnSensor=filter(B,1,GPStotalacc_OnSensor); % all GPS corrections
  
  fgps_Evel=filtfilt(B,1,gps_Evel);
  fgps_Nvel=filtfilt(B,1,gps_Nvel);
  ftide=filtfilt(B,1,tide);
  
  gpsacclong(1:10)=0;
 gpsacclong(end-10:end)=0;
  fgpsacclong=filtfilt(B,1, gpsacclong);
  gpsacccross(1:10)=0;
 gpsacccross(end-10:end)=0;
  fgpsacccross=filtfilt(B,1, gpsacccross);
 % fLongTilt=filtfilt(B,1,LongTilt);
 % fCrossTilt=filtfilt(B,1,CrossTilt);
 
 LevelError(1:10)=0;
 LevelError(end-10:end)=0;
  fLevelError=filtfilt(B,1,LevelError);
 % plot(fLevelError);
 
  fgps_lat=filtfilt(B,1,gps_lat);
  fgps_long=filtfilt(B,1,gps_long);
  fgps_orthoheight=filtfilt(B,1,gps_orthoheight);
  fgps_elipsoidheight=filtfilt(B,1,gps_elipsoidheight);
  Eotvos(1:10)=0;
  Eotvos(end-10:end)=0;
  fEotvos=filtfilt(B,1,Eotvos);
  fLatcorr=filtfilt(B,1,Latcorr);
  
  GPS_Corrections(1:10)=0;
  GPS_Corrections(end-10:end)=0;
  fGPS_Corrections=filtfilt(B,1,GPS_Corrections);
  
  
 

TimingGPS=-gpsacc;

fTimingGPS=filtfilt(Bt,1,TimingGPS); % 

    
 close all    
    

    
    