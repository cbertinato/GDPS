% LinupdataAirborne.m
% matlab script to course lineup in time 
% GPS and gravity data, based in their 
% correponding time tags, using matlab numtime.
% The two data sets are also adjusted to have 
% equal length


start_grav=startdata;

if start_grav > start_gps  % check if meter started after GPS data
    
shift=round((start_grav-start_gps)*sampling); % shitf fractional seconds
 % make GPS data start same time that Meter
 
fgps_Evel=fgps_Evel(shift:end);
fgps_Nvel=fgps_Nvel(shift:end);
ftide=ftide(shift:end);

% fgps_Eacc=fgps_Eacc(shift:end);
% fgps_Nacc=fgps_Nacc(shift:end);

 fgpsacclong=fgpsacclong(shift:end);
 fgpsacccross=fgpsacccross(shift:end);
% xpos=xpos(shift:end);
% ypos=ypos(shift:end);
 fLevelError=fLevelError(shift:end);
% fLongTilt=fLongTilt(shift:length(fLongTilt));
fgps_lat=fgps_lat(shift:end);
fgps_long=fgps_long(shift:end);
fgps_orthoheight=fgps_orthoheight(shift:end);
fgps_elipsoidheight=fgps_elipsoidheight(shift:end);
fEotvos=fEotvos(shift:end);
fLatcorr=fLatcorr(shift:end);
% fegm=fegm(shift:end);
fgpsacc=fgpsacc(shift:end);
fTimingGPS=fTimingGPS(shift:end);
fGPS_Corrections=fGPS_Corrections(shift:end);

% fGPStotalacc=fGPStotalacc(shiftlength(fGPtotalSacc));
% fsimlong=fsimlong(shift:end);
% fsimcross=fsimcross(shift:end);
% ftimingps=ftimingps(shift:end);     % !!!!!!!!!

else
%the GPS started after Meter data  
% shift the so the Meter sequence starts same time that GPS 
shift=round((start_gps-start_grav)*sampling);  
% ftime=ftime(shift:length(ftime));
fgrav=fgrav(shift:end); % filter gravity - drift+goffset // full field  
fgrav_plot=fgrav(shift:end); % filter gravity - drift+goffset // full field  
fdat.laccel=fdat.laccel(shift:end);
fdat.xaccel=fdat.xaccel(shift:end);
fdat.beam=fdat.beam(shift:end);
fdat.temp=fdat.temp(shift:end);
fdat.pressure=fdat.pressure(shift:end);
fdat.Etemp=fdat.Etemp(shift:end);
fvcc=fvcc(shift:end);
fve=fve(shift:end);
flc=flc(shift:end);
fxc=fxc(shift:end);
fal=fal(shift:end);
fax=fax(shift:end);
meterg=meterg(shift:end);
ddg=ddg(shift:end);

dat.GPSWeek=dat.GPSWeek(shift:end);
dat.WeekSeconds=dat.WeekSeconds(shift:end);
status=dat.status(shift:end);


% fdat.vcc=fdat.vcc(shift:length(fdat.vcc));
% fdat.al=fdat.al(shift:length(fdat.al));
% fdat.ax=fdat.ax(shift:length(fdat.ax));
% fdat.ve=fdat.ve(shift:length(fdat.ve));


% rt_acclong=rt_acclong(shift:length(rt_acclong));

% NewGrav=NewGrav(shift:length(NewGrav));

 ftiming_Meter=ftiming_Meter(shift:end); 
end    
 
% make all arrays same length

if length(fgps_Evel)>length(fgrav)
    z=length(fgrav);
   else
    z=length(fgps_Evel);
end   

fgps_Evel=fgps_Evel(1:z);
fgps_Nvel=fgps_Nvel(1:z);
fTimingGPS=fTimingGPS(1:z);

% fgps_Eacc=fgps_Eacc(1:z);
% fgps_Nacc=fgps_Nacc(1:z);
 fgpsacclong=fgpsacclong(1:z);
 fgpsacccross=fgpsacccross(1:z);
 fLevelError=fLevelError(1:z);
% fLongTilt=fLongTilt(1:z);
fgps_lat=fgps_lat(1:z);
fgps_long=fgps_long(1:z);
ftide=ftide(1:z);
fgps_orthoheight=fgps_orthoheight(1:z);
fgps_elipsoidheight=fgps_elipsoidheight(1:z);
% fegm=fegm(1:z);

fgrav=fgrav(1:z);
fgrav_plot=fgrav(1:z);
fEotvos=fEotvos(1:z);
fLatcorr=fLatcorr(1:z);
fGPS_Corrections=fGPS_Corrections(1:z);
fgpsacc=fgpsacc(1:z);
% fsimlong=fsimlong(1:z);
% fsimcross=fsimcross(1:z);
 fdat.laccel=fdat.laccel(1:z); % Meter long accelereometer in Gals
 fdat.xaccel=fdat.xaccel(1:z); % Meter Cross accelerometer in Gals
 fdat.beam=fdat.beam(1:z);
fdat.temp=fdat.temp(1:z);
fdat.pressure=fdat.pressure(1:z);
fdat.Etemp=fdat.Etemp(1:z);

fvcc=fvcc(1:z);
 fve=fve(1:z);
  flc=flc(1:z);
   fxc=fxc(1:z);
   fal=fal(1:z);
 fax=fax(1:z);
meterg=meterg(1:z);
 ddg=ddg(1:z);
 status=dat.status(1:z);
 
 dat.GPSWeek=dat.GPSWeek(1:z);
 dat.WeekSeconds=dat.WeekSeconds(1:z);

ftiming_Meter=ftiming_Meter(1:z);


 


