 % FixComError.m
% This program Generates a new file cropp and with 
% comunication bad data point fixed
% plot(diff(diff(dat.grv(165950:166000))))
 % plot(diff(diff(dat.grv)));
 clear;
 % init the env data structure
 Per=0.1;

  [file p] = uigetfile('p\*.*','Load DGS data file file');
  fname=[p file] ;
  save oldpath  p;
  % Now get the data   
  in=ReadAT1A(fname);
  fprintf('Readed file %s \n',fname); 
  
metertime=GPStimetoMLT(in.GPSweek,in.Weekseconds)*24*3600; % seconds;

startdata=metertime(1);   
enddata=metertime(end);
interval=diff(metertime);
Gaps=find(abs(interval) > Per*1.5);

plot(interval);
  
 
[posw,gvalw] = ginput(2); 
 x=round(posw(1));
 y=round(posw(2));
 
  in.gravity=in.gravity(x:y);
  in.long =in.long(x:y);
  in.cross =in.cross(x:y);
  in.beam=in.beam(x:y);
  in.temp=in.temp(x:y);
  in.status=in.status(x:y);
  in.pressure =in.pressure(x:y);
  in.Etemp=in.Etemp(x:y);
  in.GPSweek=in.GPSweek(x:y);
  in.Weekseconds=in.Weekseconds(x:y);
  
  
  metertime=GPStimetoMLT(in.GPSweek,in.Weekseconds)*24*3600; % seconds;

startdata=metertime(1);   
enddata=metertime(end);
interval=diff(metertime);
Gaps=find(abs(interval) > Per*1.5);

if (~isempty(Gaps))
uiwait(msgbox('Data gaps detected continue?','Message','none'));
plot(interval);
end
 
 
 g=in.gravity;
 cg=medfilt1(g,3);
 d=cg-g;
 dab=abs(d);
 x=find(d>20);
 
 
 if (1==1) % repair time when time gets to unsincronized
     
 dsample=length(in.Weekseconds);
 beg=round(in.Weekseconds(1)*10)/10;
 nonend=beg+dsample*0.1;
 
  in.Weeksecondsfix=linspace(in.Weekseconds(2),nonend,dsample)'; % new generated time vector
  in.Weekseconds= in.Weeksecondsfix;
 end    
 in.Weekseconds(1:10)

 scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('Data');
 ax1=subplot(4,1,1);
 plot(g),title('gravity');
 ax2=subplot(4,1,2);
 plot(d),title('error');
 ax3=subplot(4,1,3);
 plot(diff(g)),title('diff');
 ax(4)=subplot(4,1,4);
 plot(diff(diff(g))),title('ddiff');    
 linkaxes([ax1 ax2 ax3],'x');
 
%  save in this format
% [gravity,long,cross,beam,temp,status,pressure,Etemp,GPSweek,Weekseconds]=...
% textread(fname,['%f %f %f %f %f %f %f %f %f %f %*[^\n]'],'delimiter',',');

myname='fixedtest';
fname2=[p myname file];

tosave=[g'; in.long'; in.cross'; in.beam'; in.temp'; in.status'; in.pressure'; in.Etemp'; in.GPSweek'; in.Weekseconds'];

% tosave=[in.gravity'; in.long'; in.cross'; in.beam'; in.temp'; in.status'; in.pressure'; in.Etemp'; in.GPSweek'; in.Weekseconds'];
 fid = fopen(fname2,'a');
 fprintf(fid,'%8.3f ,%8.3f ,%8.3f ,%8.3f ,%8.3f ,%d ,%8.3f ,%8.3f ,%d ,%12.3f \r\n',tosave);
 fclose(fid);
 
 % check if gaps are real
 
 l1=length(in.Weekseconds)*0.1-0.1;
 l2=in.Weekseconds(end)-in.Weekseconds(1);
 
errort=abs(l2-l1)
if errort < 0.0001
    
fprintf('\n');
fprintf('No samples missing  \n'); 
end    
 
 
 



  
   
   