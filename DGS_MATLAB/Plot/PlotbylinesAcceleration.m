 % Plot lines
mycolor={'black','green','blue','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow'};

 n = inputdlg('Filter length','Line',1,{'100'});
filtertime= str2num(char(n));

 filterlength=filtertime;    % 
 Taps=2*filterlength*sampling; % 
 B= fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 1 sec data

 nlin=noflines;
figure
for l=1:nlin
    
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,llong{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);
    
  plot(x,1000*y,mycolor{:,l}),title('Long Accelerometer');
hold on
end

figure
for l=1:nlin
    
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,lcross{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);  
    
  plot(x,1000*y,mycolor{:,l}),title('Cross Accelerometer');
hold on
end

figure
for l=1:nlin
     x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,lfgpsacccross{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);  
    
  plot(x,y,mycolor{:,l}),title('GPS Cross ');
hold on
end


figure
for l=1:nlin
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,lfgpsacclong{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);    
    
  plot(x,y,mycolor{:,l}),title('GPS Long');
hold on
end

