% Read raw meter Marine data

filterlength=100;
sampling=100;
cal=450000;
Lat=39.909286;
Lon=-105.074830;
offset=0;

time='02/09/201618:23:00.000';
startgps=datenum(time,'mm/dd/yyyyHH:MM:ss.FFF')*24*3600;


Taps=2*filterlength*sampling; % 
 B = fir1(Taps,1/Taps,blackman(Taps+1));
 
  [file p] = uigetfile('*.*','Load Raw file');
 fname=[p file] ;
 [head,gravity] = textread(fname,'%s%d%*[^\n]','delimiter',',','headerlines',1);
 fg=cal/8388607*filter(B,1,gravity)+offset;
 fg=fg-mean(fg);
  
  
  
 
  
  
  dt=0:(length(fg)-1);
  t=startgps+dt;
  
  a=zeros(1,length(fg));
  gps_long=a+Lon;
  gps_lat=a+Lat;
  
  
  tide=LongmanTidePredictor(gps_long,gps_lat,t/24/3600); % calculate correction
  
  plot(fg)
  hold on
  plot(-tide,'red');
  
  
  std(fg-mean(fg)+tide)
  