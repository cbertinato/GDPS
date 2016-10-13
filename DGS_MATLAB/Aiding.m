%  Calculate the filter coefficients
filtertime=0.1;
sampling=100;
 filterlength=filtertime*sampling;
 Taps=2*filterlength; % 
 B = fir1(Taps,1/Taps,blackman(Taps+1));
 
% load Aiding;
 x=1;
%  y=11820; 
 y=17420;
  figure
  longacc=filtfilt(B,1,Test(:,2));
  plot(longacc(x:y)),title('Long acc');
  
  crossacc=filtfilt(B,1,Test(:,3)); 
  figure
   plot(crossacc(x:y)),title('cross acc');
   
   figure
   Nacc=filtfilt(B,1,Test(:,4));
  plot(Nacc(x:y)),title('GPS Long');
   figure
   Eacc=filtfilt(B,1,Test(:,5));
  plot(Eacc(x:y)),title('GPS cross');
  
  figure
   Nvel=filtfilt(B,1,Test(:,6));
  plot(Nvel(x:y)),title('Nvel');
  
   figure
   Evel=filtfilt(B,1,Test(:,7));
  plot(Evel(x:y)),title('Evel');
  
     figure
   Azim=filtfilt(B,1,Test(:,8));
  plot(Azim(x:y)),title('Azimuth');
  
   figure
   GPSlat=filtfilt(B,1,Test(:,9));
  plot(GPSlat(x:y)),title('GPS Lat');
   figure
   GPSlong=filtfilt(B,1,Test(:,10));
  plot(GPSlong(x:y)),title('GPS cross');
   figure
   GPSh=filtfilt(B,1,Test(:,11));
  plot(GPSh(x:y)),title('GPS h');
   