mycolor={'blue','green','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow','black','blue','green','cyan','red','magenta','yellow'}; 
 morecolor={'b.:','g.:','c.:','r.:','m.:','y.:','b.:','g.:'};
 
 n = inputdlg('Filter length','Line',1,{'100'});
filtertime= str2num(char(n));

filterlength=filtertime;    % 
Taps=2*filterlength*sampling; % 
B= fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 1 sec data
 
 
 figure

for l=1:id-1
    
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,GravityFreeAir{:,l});
   x=x(Taps:end-Taps); 
   y=y(Taps:end-Taps);  
    
  plot(x,y,mycolor{:,l}),title('Meter Gravity');
hold on
end
figure

for l=1:id-1
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,lal{:,l});
   x=x(Taps:end-Taps); 
   y=y(Taps:end-Taps);  
    
  plot(x,y,mycolor{:,l}),title('AL');
hold on
end

figure

for l=1:id-1
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,lax{:,l});
   x=x(Taps:end-Taps); 
   y=y(Taps:end-Taps);   
    
  plot(x,y,mycolor{:,l}),title('AX');
hold on
end

figure

for l=1:id-1
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,lvcc{:,l});
   x=x(Taps:end-Taps); 
   y=y(Taps:end-Taps);     
  plot(x,y,mycolor{:,l}),title('Vcc');
hold on
end

figure

for l=1:id-1
    x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,lve{:,l});
   x=x(Taps:end-Taps); 
   y=y(Taps:end-Taps);     
 
  plot(x,y,mycolor{:,l}),title('VE');
hold on
end

figure

for l=1:id-1
     x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,llc{:,l});
   x=x(Taps:end-Taps); 
   y=y(Taps:end-Taps);     
  plot(x,y,mycolor{:,l}),title('LC');
hold on
end

figure

for l=1:id-1
     x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,lxc{:,l});
   x=x(Taps:end-Taps); 
   y=y(Taps:end-Taps);     
  
  plot(x,y,mycolor{:,l}),title('xc');
hold on
end

figure

for l=1:id-1
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,lvcc{:,l});
   z=filtfilt(B,1,llong{:,l});
   x=x(Taps:end-Taps); 
   y=y(Taps:end-Taps);  
   z=z(Taps:end-Taps);  
   
  plot(x,y./z/1000,mycolor{:,l}),title('beam');
hold on
end







