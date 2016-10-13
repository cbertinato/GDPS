% Plot lines

% load thelines
id=noflines+1;

mycolor={'blue','green','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow','black','blue','green','cyan','red','magenta','yellow'};
 morecolor={'b.:','g.:','c.:','r.:','m.:','y.:','b.:','g.:','b.:','g.:','c.:','r.:','m.:','y.:','b.:','g.:','b.:','g.:','c.:','r.:','m.:','y.:','b.:','g.:'};

  n = inputdlg('Filter length','Line',1,{'100'});
filtertime= str2num(char(n));

 filterlength=filtertime;    % 
 Taps=2*filterlength*sampling; % 
 B= fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 1 sec data
 
 
 
 figure
% id=n+1;

for l=1:id-1
   x=filtfilt(B,1,lgpslat{:,l});
   y=filtfilt(B,1,lmeterPgrav{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);
   
plot(x,y,mycolor{:,l}),title('Meter Gravity');
hold on
end


figure
for l=1:id-1
   x=filtfilt(B,1,lgpslat{:,l});
   y=filtfilt(B,1,Gravity{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);   
 
plot(x,y,mycolor{:,l}),title('Full field Gravity ');
hold on
end

for l=1:id-1
    x=filtfilt(B,1,lgpslat{:,l});
   y=filtfilt(B,1,legm{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);    
 plot(x,y,morecolor{:,l});
end
MaxShift=6000;
figure
for l=1:id-1

 if 1==0 % shitf the level correct
 
 % get integer time offset between grav and GPS
 [xc,lags]=xcorr(-lLevelError{:,l},GravityFreeAir{:,l},MaxShift);
 dt=FindDT(lags,xc);
 dt
 lLevelErrorx{:,l}=FTPhaseShift(lLevelError{:,l},dt,1);
  
 end

   x=filtfilt(B,1,lgpslat{:,l});
   y=filtfilt(B,1,GravityFreeAir{:,l});
   z=filtfilt(B,1,lLevelError{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);    
   z=z(Taps:end-Taps);    
 
     plot(x,y+z,mycolor{:,l}),title('FreeAir Gravity');
% plot(x,y,mycolor{:,l}),title('FreeAir Gravity');
 
hold on
 y=filtfilt(B,1,legm{:,l});
 y=y(Taps:end-Taps);  
 z=filtfilt(B,1,lfLatcorr{:,l});
 z=z(Taps:end-Taps);   
 
plot(x,y+z,morecolor{:,l});
end

 
figure
for l=1:id-1
     y=filtfilt(B,1,lgpsacc{:,l});
      y=y(Taps:end-Taps);   
   x=filtfilt(B,1,lgpslat{:,l}); 
    x=x(Taps:end-Taps);
    
  plot(x,y,mycolor{:,l}),title('gpsacc');
hold on
end

figure
for l=1:id-1
     y=filtfilt(B,1,lfEotvos{:,l});
      y=y(Taps:end-Taps);   
       x=filtfilt(B,1,lgpslat{:,l}); 
    x=x(Taps:end-Taps);
  plot(x,y,mycolor{:,l}),title('Eotvos');
hold on
end


figure
for l=1:id-1
     y=filtfilt(B,1,lfLatcorr{:,l});
      y=y(Taps:end-Taps);
       x=filtfilt(B,1,lgpslat{:,l}); 
    x=x(Taps:end-Taps);
    
  plot(x,y,mycolor{:,l}),title('lat correction');
hold on
end

figure
for l=1:id-1
     y=filtfilt(B,1,lLevelError{:,l});
      y=y(Taps:end-Taps);   
       x=filtfilt(B,1,lgpslat{:,l}); 
    x=x(Taps:end-Taps);
    
  plot(x,y,mycolor{:,l}),title('Level correction');
hold on
end 


pause
close all

