  % Plot lines

% load thelines
filtertype=0; % select 0 for Blacman FIR or 1 for gausian filter
lines=size(lmeter); % find how many lines to plot
id=lines(2)+1;   
  
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
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,lmeterPgrav{:,l});
   x=x(Taps:end-Taps); 
   y=y(Taps:end-Taps);
   
plot(x,y,mycolor{:,l}),title('Meter Gravity');
hold on
end


figure
for l=1:id-1
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,Gravity{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);   
 
plot(x,y,mycolor{:,l}),title('Full field Gravity ');
hold on
end

% for l=1:id-1
%     x=filtfilt(B,1,lgpslong{:,l});
%    y=filtfilt(B,1,legm{:,l});
%    x=x(Taps:end-Taps);
%    y=y(Taps:end-Taps);    
%  plot(x,y,morecolor{:,l});
% end
MaxShift=6000;
figure
for l=1:id-1

 if filtertype==0

   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,GravityFreeAir{:,l});
   z=filtfilt(B,1,lLevelError{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);    
   z=z(Taps:end-Taps); 
   plot(x,y,mycolor{:,l}),title('FreeAir Gravity');
    hold on
%     y=filtfilt(B,1,l {:,l});
%     y=y(Taps:end-Taps);  
%     z=filtfilt(B,1,lfLatcorr{:,l});
%      z=z(Taps:end-Taps);   
%     plot(x,y+z,morecolor{:,l});
 else 
    
   ns=length(GravityFreeAir{:,l}); 
   mt=0:0.1:ns/10-1;
   y=gaussian_filter(mt,GravityFreeAir{:,l},filtertime,3);
   x=gaussian_filter(mt,lgpslong{:,l},filtertime,3);
    
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);  
   
   plot(x,y,mycolor{:,l}),title('FreeAir Gravity Gausian filter'); 
   
   
end   
   
 %  plot(x,y+z,mycolor{:,l}),title('FreeAir Gravity Level corrected');
 % plot(x,y,mycolor{:,l}),title('FreeAir Gravity');
 
hold on
%  y=filtfilt(B,1,legm{:,l});
%  y=y(Taps:end-Taps);  
%  z=filtfilt(B,1,lfLatcorr{:,l});
%  z=z(Taps:end-Taps);   
% plot(x,y+z,morecolor{:,l});
end

figure

for l=1:id-1

 if 1==0 % shitf the level correct
 
 % get integer time offset between grav and GPS
 [xc,lags]=xcorr(-lLevelError{:,l},GravityFreeAir{:,l},MaxShift);
 dt=FindDT(lags,xc);
 dt
 lLevelErrorx{:,l}=FTPhaseShift(lLevelError{:,l},dt,1);
  
 end

   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,GravityFreeAir{:,l});
   z=filtfilt(B,1,lLevelError{:,l});
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);    
   z=z(Taps:end-Taps);    
 
    plot(x,y+z,mycolor{:,l}),title('FreeAir Gravity Level corrected');
 % plot(x,y,mycolor{:,l}),title('FreeAir Gravity');
 
hold on
%  y=filtfilt(B,1,legm{:,l});
%  y=y(Taps:end-Taps);  
%  z=filtfilt(B,1,lfLatcorr{:,l});
%  z=z(Taps:end-Taps);   
%  
% plot(x,y+z,morecolor{:,l});
end



 
figure
for l=1:id-1
     y=filtfilt(B,1,lgpsacc{:,l});
      y=y(Taps:end-Taps);   
   x=filtfilt(B,1,lgpslong{:,l}); 
    x=x(Taps:end-Taps);
    
  plot(x,y,mycolor{:,l}),title('gpsacc');
hold on
end

figure
for l=1:id-1
     y=filtfilt(B,1,lfEotvos{:,l});
      y=y(Taps:end-Taps);   
       x=filtfilt(B,1,lgpslong{:,l}); 
    x=x(Taps:end-Taps);
  plot(x,y,mycolor{:,l}),title('Eotvos');
hold on
end


figure
for l=1:id-1
     y=filtfilt(B,1,lfLatcorr{:,l});
      y=y(Taps:end-Taps);
       x=filtfilt(B,1,lgpslong{:,l}); 
    x=x(Taps:end-Taps);
    
  plot(x,y,mycolor{:,l}),title('lat correction');
hold on
end

figure
for l=1:id-1
     y=filtfilt(B,1,lLevelError{:,l});
      y=y(Taps:end-Taps);   
       x=filtfilt(B,1,lgpslong{:,l}); 
    x=x(Taps:end-Taps);
    
  plot(x,y,mycolor{:,l}),title('Level correction');
hold on
end 

figure
for l=1:id-1
     y=filtfilt(B,1,lgps_height{:,l});
      y=y(Taps:end-Taps);
       x=filtfilt(B,1,lgpslong{:,l}); 
    x=x(Taps:end-Taps);
    
  plot(x,y,mycolor{:,l}),title('Elipsoidal height');
hold on
end


figure
for l=1:id-1
     y=cell2mat(lstatus(:,l));
      y=y(Taps:end-Taps); 
      z=bitget(y,14);
      
       x=filtfilt(B,1,lgpslong{:,l}); 
    x=x(Taps:end-Taps);
    
  plot(x,z,mycolor{:,l}),title('Saturation');
hold on
end

figure
for l=1:id-1
     y=cell2mat(lstatus(:,l));
      y=y(Taps:end-Taps); 
      z=bitget(y,7);
      
       x=filtfilt(B,1,lgpslong{:,l}); 
    x=x(Taps:end-Taps);
    
  plot(x,z,mycolor{:,l}),title('AD lock');
hold on
end

figure
for l=1:id-1
     y=cell2mat(lbeam(:,l));
      y=y(Taps:end-Taps); 
      x=filtfilt(B,1,lgpslong{:,l}); 
       x=x(Taps:end-Taps);
    
  plot(x,y,mycolor{:,l}),title('Beam');
hold on
end

pause
close all
 

