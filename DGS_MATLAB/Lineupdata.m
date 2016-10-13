% Linupdata
% matlab script to course lineup in time 
% GPS and gravity data, based in their 
% correponding time tags, using matlab numtime.
% The two data sets are also adjusted to have 
% equal length

start_grav=startdata;

if start_grav > start_gps  % check if meter started after GPS data
shift=round(start_grav-start_gps);

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
fgpsacc=fgpsacc(shift:end);
fTimingGPS=fTimingGPS(shift:end);
fGPS_Corrections=fGPS_Corrections(shift:end);

% fGPStotalacc=fGPStotalacc(shiftlength(fGPtotalSacc));
% fsimlong=fsimlong(shift:end);
% fsimcross=fsimcross(shift:end);
% ftimingps=ftimingps(shift:end);     % !!!!!!!!!

else
% gps atarted latter   

shift=round(start_gps-start_grav);  


% ftime=ftime(shift:length(ftime));
fgrav=fgrav(shift:length(fgrav));
fdat.vcc=fdat.vcc(shift:length(fdat.vcc));
fdat.al=fdat.al(shift:length(fdat.al));
fdat.ax=fdat.ax(shift:length(fdat.ax));
fdat.ve=fdat.ve(shift:length(fdat.ve));

fdat.laccel=fdat.laccel(shift:length(fdat.laccel));
fdat.xaccel=fdat.xaccel(shift:length(fdat.xaccel));
fdatll2=fdat.l2(shift:end);
fdat.x2=fdat.x2(shift:end);
 rt_acclong=rt_acclong(shift:length(rt_acclong));

% NewGrav=NewGrav(shift:length(NewGrav));

 ftiming_Meter=ftiming_Meter(shift:end); 
end    
 
% make all same length
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
ftidet=ftide(1:z);
fgps_orthoheight=fgps_orthoheight(1:z);
fgps_elipsoidheight=fgps_elipsoidheight(1:z);
fgrav=fgrav(1:z);
fEotvos=fEotvos(1:z);
fLatcorr=fLatcorr(1:z);
fGPS_Corrections=fGPS_Corrections(1:z);
fgpsacc=fgpsacc(1:z);
% fsimlong=fsimlong(1:z);
% fsimcross=fsimcross(1:z);


 fdat.vcc=fdat.vcc(1:z);
 fdat.al=fdat.al(1:z);
 fdat.ax=fdat.ax(1:z);
 fdat.ve=fdat.ve(1:z);
 rt_acclong=rt_acclong(1:z);
% fdat.ax2=fdat.ax2(1:z);
 fdat.laccel=fdat.laccel(1:z); % Meter long accelereometer in Gals
 fdat.xaccel=fdat.xaccel(1:z); % Meter Cross accelerometer in Gals
 fdat.l2=fdat.l2(1:z);
 fdat.x2=fdat.x2(1:z);
% ftime=ftime(1:z);
% fdat.lacc2=fdat.lacc2(1:z);
% fdat.xacc2=fdat.xacc2(1:z);

% fE=fE(1:z); 

% xpos=xpos(1:z);
%ypos=ypos(1:z);

% NewGrav=NewGrav(1:z);

 ftiming_Meter=ftiming_Meter(1:z);
% ftimingps=ftimingps(1:z);     % !!!!!!!!!

% fTCgrav=fgrav+fEotvos-fgpsacc+fLatcorr;
 
% fTCgrav=fgrav+fGPS_Corrections;
% fTCgrav=fgrav+fEotvos;


 


