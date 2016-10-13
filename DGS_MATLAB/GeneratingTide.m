% GenerateTides


periode=0.1;
% DGS position
Lat=39.909286;
Lon=-105.074830;

% ECON Position


meter=meterg(2500:end-2500);

time='02/11/201614:43:52.000';
startgps=datenum(time,'mm/dd/yyyyHH:MM:ss.FFF')*24*3600;

 dt=0:periode:(length(meter)/10);
 dt=dt(1:end-1);
 
 t=startgps+dt;
  
  a=zeros(1,length(meter));
  gps_long=a+Lon;
  gps_lat=a+Lat;
  
  tide=LongmanTidePredictor(gps_long,gps_lat,t/24/3600); % calculate correction
  
  plot(meter-mean(meter))
  hold on
  plot(-tide,'red');