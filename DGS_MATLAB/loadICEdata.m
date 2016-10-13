% Load ICE data %

 n = inputdlg('Filter length','Line',1,{'100'});
filtertime= str2num(char(n));

 filterlength=filtertime;    % 
 Taps=2*filterlength*sampling; % 
 B= fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 1 sec data
 

load comdata.mat
ICElong=untitled(:,2);
ICElat=untitled(:,1);
ICEgrav=untitled(:,4); % 5 140 sec, 4 100 sec, 3 50 sec
dc=0;

len=length(ICElong);

  
    for t=1:1:len
        
          if (ICElong(t)<0) 
           ICElong_noflip(t)=ICElong(t)+360;
          else
           ICElong_noflip(t)=ICElong(t);  
          end
          
    end  
    
 line=1;  
 linelog=cell2mat(lgpslong(:,line));
 za=cell2mat(lLevelError(:,line)); % level monitor
 zxc=cell2mat(lxc(:,line));         %  cross acc monitor
 zlc=cell2mat(llc(:,line));         %  long accelerometer monitor
 zve=cell2mat(lve(:,line));         %  ve
 zvcc=cell2mat(lvcc(:,line));         %  vcc
 zxacc=cell2mat(lfgpsacccross(:,line)); %cross Gpas acceleration
 mg=cell2mat(lmeterg(:,line)); 
 linegrav=cell2mat(GravityFreeAir(:,line));
 
 % filter with the selected filter
 linegrav=filtfilt(B,1,linegrav);
 linegrav=linegrav(Taps:end-Taps);
 linelog=filtfilt(B,1,linelog);
 linelog=linelog(Taps:end-Taps);
 za=filtfilt(B,1,za);
 za=za(Taps:end-Taps);
  zxc=filtfilt(B,1,zxc);
 zxc=zxc(Taps:end-Taps);
  zlc=filtfilt(B,1,zlc);
 zlc=zlc(Taps:end-Taps);
  zve=filtfilt(B,1,zve);
 zve=zve(Taps:end-Taps);
  zvcc=filtfilt(B,1,zvcc);
 zvcc=zvcc(Taps:end-Taps);
  zxacc=filtfilt(B,1,zxacc);
 zxacc=zxacc(Taps:end-Taps);
  mg=filtfilt(B,1,mg);
 mg=mg(Taps:end-Taps);
 
 
 
 
 
 
 
 
 
 unc_grav= linegrav;

 
 if 1==0
  MaxShift=1000;
 % get integer time offset between grav and GPS
 [xc,lags]=xcorr(-za,linegrav,MaxShift);
 dt=FindDT(lags,xc);
 za=FTPhaseShift(za,dt,0.1);
  linegrav=linegrav+za;
 end
 
plot(linelog,linegrav,'blue'),title('FreeAir Gravity Uncompensated comparation');
hold on
plot(ICElong_noflip,ICEgrav,'green');

error=[];
mypos=[];

first=100;
last=len-1000;

% Plot error before fitting data

for n=first:last
    
  I=find(linelog > ICElong_noflip(n)); 
  error(n)=linegrav(I(1))-ICEgrav(n);
  mypos(n)=ICElong_noflip(n);
    
end

figure
error=error(first:end);
mypos=mypos(first:end);

plot(mypos,error,'green'),title('Uncompensated error');

fprintf('\n');
fprintf('Error before compensation\n');
meanerror=mean(error);
abserr=abs(error);
mean_abs_error=mean(abserr);
mysigma=std(error);

fprintf('Mean Error= %f\n',meanerror);
fprintf('Mean absolute Error= %f \n',mean_abs_error);
fprintf('Std = %f \n',mysigma);
fprintf('\n');
fprintf('\n');


x0=[];
x1=[];
x2=[];
x3=[];
x4=[];
x5=[];
x6=[];
cc=[];
 y=[]; 
 
 
for n=first:last
    
  I=find(linelog > ICElong_noflip(n)); 
  
  x0(n)=linegrav(I(1));
   x1(n)=zve(I(1));
   x2(n)=zvcc(I(1));
   x3(n)=zxc(I(1));
   x4(n)=zlc(I(1));
   x5(n)=za(I(1));
   x6(n)=mg(I(1));
   y(n)=ICEgrav(n);
   
    
end 
x0=x0';
x1=x1';
x2=x2';
x3=x3';
x4=x4';
x5=x5';
x6=x6';
y=y';
error=y-x0;
dc=ones(length(x0),1);

% select the type of fitting


fit=4;

switch fit
         
     case 0
     % Gain vcc xc xl level 
     cc=[x6 x2 x3 x4 x5]; 
     mycoef=lscov(cc,-error); 
     P=-mycoef;
     
     fprintf('\n');
     fprintf('Gain= %f\n',P(1));
     fprintf('vcc= %f\n',P(2));
     fprintf('xc= %f\n',P(3));
     fprintf('lc= %f\n',P(4));
     fprintf('level= %f\n',P(5));
     
     linegrav=linegrav+P(1)*mg+P(2)*zvcc+P(3)*zxc+P(4)*zlc+P(5)*za;
     
     case 1
     % Gain dc
     cc=[x6 dc]; 
     mycoef=lscov(cc,-error); 
     P=-mycoef;
     linegrav=linegrav-P(1)*mg;
     fprintf('\n');
     fprintf('Gain= %f\n',P(1));
     
     
      case 2
     % Gain vcc xc xl  
     cc=[x6 x2 x3 x4]; 
     mycoef=lscov(cc,-error); 
     P=-mycoef;
     
     fprintf('\n');
     fprintf('Gain= %f\n',P(1));
     fprintf('vcc= %f\n',P(2));
     fprintf('xc= %f\n',P(3));
     fprintf('lc= %f\n',P(4));
     
     
     linegrav=linegrav+P(1)*mg+P(2)*zvcc+P(3)*zxc+P(4)*zlc;
     
     
     
    case 3    
        % Gain ve vcc xc xl level dc
      cc=[x6 x1 x2 x3 x4 x5 dc];   
      mycoef=lscov(cc,-error);      
      P=-mycoef;   
      
     fprintf('\n');
     fprintf('Gain= %f\n',P(1));
     fprintf('ve= %f\n',P(2));
     fprintf('vcc= %f\n',P(3));
     fprintf('xc= %f\n',P(4));
     fprintf('lc= %f\n',P(5));
     fprintf('level= %f\n',P(6));
      
     linegrav=linegrav+P(1)*mg+P(2)*zve+P(3)*zvcc+P(4)*zxc+P(5)*zlc+P(6)*za+P(7);
      
     case 4
     % Gain vcc level dc 
     cc=[x6 x2 x5 dc]; 
     mycoef=lscov(cc,-error); 
     P=-mycoef;
     
     fprintf('\n');
     fprintf('Gain= %f\n',P(1));
     fprintf('vcc= %f\n',P(2));
     fprintf('level= %f\n',P(3));
     fprintf('dc= %f\n',P(4));
     
     
     linegrav=linegrav+P(1)*mg+P(2)*zvcc+P(3)*za+P(4);
     
      
end        

figure
plot(linelog,linegrav,'blue'),title('FreeAir Gravity compensated');
hold on
plot(ICElong_noflip,ICEgrav,'green');


error=[];
mypos=[];

for n=first:last
    
  I=find(linelog > ICElong_noflip(n)); 
  error(n)=linegrav(I(1))-ICEgrav(n);
  mypos(n)=ICElong_noflip(n);
    
end

figure
error=error(first:end);
mypos=mypos(first:end);

plot(mypos,error,'green');

fprintf('\n');
fprintf('Error for compensated\n');

meanerror=mean(error);
abserr=abs(error);
mean_abs_error=mean(abserr);
mysigma=std(error);
fprintf('Mean Error= %f\n',meanerror);
fprintf('Mean absolute Error= %f \n',mean_abs_error);
fprintf('Std = %f \n',mysigma);
fprintf('\n');
fprintf('\n');

 correction=unc_grav-linegrav;

 scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('Monitor comparation');
 ax1=subplot(4,1,1);
 plot(linelog,linegrav),title('GPS vertical acc');
 ax2=subplot(4,1,2);
 plot(linelog,za),title('level');
 ax3=subplot(4,1,3);
 plot(linelog,correction),title('correction');
 ax4=subplot(4,1,4);
 plot(linelog,unc_grav),title('uncorrected grav');    
 linkaxes([ax1 ax2 ax3 ax4],'x');
 
 
    
  scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('Monitor comparation');
 ax1=subplot(4,1,1);
 plot(linelog,unc_grav),title('uncorrected grav');
 ax2=subplot(4,1,2);
 plot(linelog,zxc),title('xc');
 ax3=subplot(4,1,3);
 plot(linelog,zxacc),title('cross accelerometer');
 ax4=subplot(4,1,4);
 plot(linelog,za),title('level');    
 linkaxes([ax1 ax2 ax3 ax4],'x');



