
clc
% Plot lines

% load thelines
% id=noflines+1;

FixedLines=0;


mycolor={'blue','green','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow','black','blue','green','cyan','red','magenta','yellow'};
 morecolor={'b.:','g.:','c.:','r.:','m.:','y.:','b.:','g.:','b.:','g.:','c.:','r.:','m.:','y.:','b.:','g.:','b.:','g.:','c.:','r.:','m.:','y.:','b.:','g.:'};

 
 n = inputdlg('Line number','Line',1,{'0'});
linenumber= str2num(char(n));

  
 n = inputdlg('Filter length','Line',1,{'100'});
filtertime= str2num(char(n));

 filterlength=filtertime;    % 
 Taps=2*filterlength*sampling; % 
 B= fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 1 sec data
 
 
 % id=n+1;
MaxShift=6000;
figure
l=linenumber;

 if 1==0 % shitf the level correct
 
 % get integer time offset between grav and GPS
 [xc,lags]=xcorr(-lLevelError{:,l},GravityFreeAir{:,l},MaxShift);
 dt=FindDT(lags,xc);
 
 lLevelErrorx{:,l}=FTPhaseShift(lLevelError{:,l},dt,1);
  
 end
 
 if FixedLines==1;
     
    y=cell2mat(T_GravityFreeAir_Final(:,l));
    x=filtfilt(B,1,lgpslong{:,l});
    z=filtfilt(B,1,lLevelError{:,l});
    x=x(Taps:end-Taps);
    z=z(Taps:end-Taps);    
    
 else
   x=filtfilt(B,1,lgpslong{:,l});
   y=filtfilt(B,1,GravityFreeAir{:,l});
   z=filtfilt(B,1,lLevelError{:,l});
   z=1*z;
   x=x(Taps:end-Taps);
   y=y(Taps:end-Taps);    
   z=z(Taps:end-Taps);    
   
 end  
 
  %   plot(x,y+z,mycolor{:,l}),title('FreeAir Gravity');
  plot(x,y,mycolor{:,l}),title('FreeAir Gravity');
  
  
  hold on
 plot(x,y+z,mycolor{:,l+1}),title('FreeAir Gravity');
hold on
 y=filtfilt(B,1,legm{:,l});
 y=y(Taps:end-Taps);  
 z=filtfilt(B,1,lfLatcorr{:,l});
 z=z(Taps:end-Taps);   
 plot(x,y+z,morecolor{:,l});
 


F=char(T_Flight{:,l});
L=char(T_Lname{:,l});
fprintf('line %d %s %s  \n',l,F,L); 

if 1==1 % plot all lines
    figure
for l=1:noflines
    
    y=filtfilt(B,1,GravityFreeAir{:,l});  
    y=y(Taps:end-Taps); 
     x=filtfilt(B,1,lgpslong{:,l});
      x=x(Taps:end-Taps);
    
     plot(x,y,mycolor{:,l}),title('FreeAir Gravity');
     hold on
end    

end

