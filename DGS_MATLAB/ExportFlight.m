% configure few option
fit=0;      % configure cc correction
FixedLines=0; % Expor as correced lines
filtertype=0; % select 0 for Blacman FIR or 1 for gausian filter
 % do things
  [file p] = uiputfile('p\*.*','Sve to file');
  fname=[p file] ;
  
  n = inputdlg('Filter length','Line',1,{'100'});
  filtertime=str2num(char(n));

%    load CCGains;
   
 filterlength=filtertime;    % 
 Taps=2*filterlength*sampling; % 
 B= fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 1 sec data 
  
fid2 = fopen(fname,'a');
fprintf(fid2,'Line number,Matlab Time,Latitude,Longitude,Ellipsoidal height,Free Air,Corrected Free Air,long acc, cross acc \r\n');
fclose(fid2);
 
for id=1:noflines
    
    if FixedLines==1 
    y=cell2mat(GravityFreeAir(:,id));  
     else     
    y=filtfilt(B,1,GravityFreeAir{:,id});
    y=y(Taps:end-Taps);    
    end
        
    ve=filtfilt(B,1,lve{:,id});
    ve=ve(Taps:end-Taps);    
    vcc=filtfilt(B,1,lvcc{:,id});
    vcc=vcc(Taps:end-Taps);    
    metr=filtfilt(B,1,lmeter{:,id});
    metr=metr(Taps:end-Taps);    
    za=filtfilt(B,1,lLevelError{:,id});
    za=za(Taps:end-Taps);    
    zlc=filtfilt(B,1,llc{:,id});
    zlc=zlc(Taps:end-Taps);    
    zxc=filtfilt(B,1,lxc{:,id});
    zxc=zxc(Taps:end-Taps);    

switch id
    case 1
    l=400;    
    case 2
    l=250;
    case 3
    l=20; 
    case 4
    l=810;  
end
Lne=repmat(l,length(y),1);
% fprintf('\n');
% fprintf('Data start %s  \n',datafiletime);   
% datafiletime=datestr(GPStimetoMLT(dat.GPSWeek(end),dat.WeekSeconds(end)));
% fprintf('\n');
% fprintf('Data end %s  \n',datafiletime);   

 d3=cell2mat(lweek(:,id)); % 1sec
 d3=d3(Taps:end-Taps); 
 d4=cell2mat(lweeksec(:,id)); % 1sec
 d4=d4(Taps:end-Taps); 
 
 dd2=GPStimetoMLT(d3,d4);
 
% datafiletime=datestr(GPStimetoMLT(d3,d4));
d5=cell2mat(lgpslat(:,id));  % filte
d5=d5(Taps:end-Taps); 
d6=cell2mat(lgpslong(:,id));  % filter
d6=d6(Taps:end-Taps); 
d7=cell2mat(lgps_height(:,id)); % filter
d7=d7(Taps:end-Taps); 
d8=cell2mat(GravityFreeAir(:,id)); % filter
d8=d8(Taps:end-Taps); 
d9=cell2mat(llong(:,id)); % filter
d9=d9(Taps:end-Taps); 
d10=cell2mat(lcross(:,id)); % filter
d10=d10(Taps:end-Taps); 

cc=0;
switch fit    
  case 2   
  cc=P(1)*ve+P(2)*vcc+P(3)*metr+P(4)*za+ P(5);  
 case 3    
cc=P(1)*ve+P(2)*vcc+P(3)*metr+P(4)*za+P(5)*zlc+P(6)*zxc+P(7); % calculate the cross couplings
end
y=y+cc; % if exporting corre

% decimate if a lower data rate is require
% N1=decimate(lgpslat{:,l},10);
% N2=decimate(lgpslong{:,l},10); 
% N3=decimate(lgps_height{:,l},10);
% N4=decimate(lorto_height{:,l},10); 
% N5=decimate(Gravity{:,l},10);
% N6=decimate(GravityFreeAir{:,l},10);
% N7=decimate(legm{:,l},10);
% N8=downsample(lweek{:,l},10);
% N9=downsample(lweeksec{:,l},10);

tosave=[Lne'; dd2'; d5'; d6'; d7'; d8'; y'; d9'; d10'];

fid2 = fopen(fname,'a');
fprintf(fid2,'%d, %15.9f, %15.9f, %15.9f, %8.3f, %9.3f,%9.3f,%9.3f,%9.3f \r\n',tosave);
fclose(fid2);
end