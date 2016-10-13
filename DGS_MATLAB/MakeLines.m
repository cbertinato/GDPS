% MakeLines.m
% Gets the GPS and Meter input arrays and and using
% input grafic generates data lines which are stored in cell variables
%-------------------------------------------------------
% select the lines
index=[1:length(fgrav)];

mycolor={'green','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow'};


 scrsz = get(0,'ScreenSize');    
 figure('Position',[100 40 scrsz(3)/1.2 scrsz(4)/1.2]),title('Select lines');
% figure(1),title('Select lines');
ax(1)=subplot(4,1,1);plot(index,fgrav),title('Gravity'); % was fTCgrav
ax(2)=subplot(4,1,2);plot(index,fgpsacc),title('Gps acc');
ax(3)=subplot(4,1,3);plot(index,fdat.laccel),title('Long acc');
ax(4)=subplot(4,1,4);plot(index,fEotvos),title('Eotvos');
 linkaxes([ax(1) ax(2) ax(3) ax(4)],'x');
  pause
n = inputdlg('how many lines?','Line',1,{'4'});
n = str2num(char(n));
nl=2*n;                   % set the number of lines x2
[pos,g] = ginput(nl); 

id=noflines+1; % 
 
for j=0:2:nl-2
  x=round(pos(j+1));
  y=round(pos(j+2));

% linePgrav{:,id}=fTCgrav(x:y);  % Total grav + GPS corrections
 lmeterPgrav{:,id}=fgrav(x:y);  % Only meter grav with only drift correction
% lGPStotalacc_OnSensor{:,id}=fGPStotalacc_OnSensor(x:y);
 lfGPS_Corrections{:,id}=fGPS_Corrections(x:y);
 llong{:,id}=fdat.laccel(x:y);
 lcross{:,id}=fdat.xaccel(x:y);
 lpress{:,id}=fdat.pressure(x:y);
 ltemp{:,id}=fdat.temp(x:y);
 lve{:,id}=fdat.ve(x:y);
 lvcc{:,id}=fdat.vcc(x:y);
 lal{:,id}=fdat.al(x:y);
 lax{:,id}=fdat.ax(x:y);
 ll2{:,id}=fdat.l2(x:y);
 lx2{:,id}=fdat.x2(x:y);
 %lbl{:,id}=fbl(x:y);
 %lbx{:,id}=fbx(x:y);
 % lax2{:,id}=fax2(x:y);
 % lal2{:,id}=fal2(x:y);
 % lx2{:,id}=fx2(x:y);
 % ll2{:,id}=fl2(x:y);
 % ldrift{:,id}=fdriftcorr(x:y);
 % lsimlong{:,id}=fsimlong(x:y);
 % lsimcross{:,id}=fsimcross(x:y);
 
 lgpslong{:,id}=fgps_long(x:y);
 lgpslat{:,id}=fgps_lat(x:y);
 lgpsacc{:,id}=fgpsacc(x:y);
 lLevelError{:,id}=fLevelError(x:y);
% lLongTilt{:,id}=fLongTilt(x:y);
 lfgpsacclong{:,id}=fgpsacclong(x:y); % just for tunning thr model
 lfgpsacccross{:,id}=fgpsacccross(x:y);
 lfLatcorr{:,id}=fLatcorr(x:y);
 lfEotvos{:,id}=fEotvos(x:y);
 lgps_height{:,id}=fgps_elipsoidheight(x:y);
 lorto_height{:,id}=fgps_orthoheight(x:y);
% lFreeair{:,id}=Freeair(x:y);
% lxpos{:,id}=xpos(x:y);
% lypos{:,id}=ypos(x:y);
 lftiming_Meter{:,id}=ftiming_Meter(x:y); % used for timming sync
 lfTimingGPS{:,id}=fTimingGPS(x:y);       % used for timming sync
 id=id+1;
 
end
close

 plot(fgps_long(200:end-200),fgps_lat(200:end-200)),title('Fligth path')
 hold on
 id=noflines+1;
 for j=0:2:nl-2
  x=round(pos(j+1));
  y=round(pos(j+2));
 plot(fgps_long(x:y),fgps_lat(x:y),mycolor{:,id});
 id=id+1;
 end
pause

close

%PlotLinesPosition;
% pause


noflines=id-1;

 save thelines lve lvcc lal lax llong lcross ll2 lx2 lfgpsacclong lfgpsacccross ...
     lpress ltemp  lgpslong lgpslat lgpsacc lmeterPgrav lfLatcorr lLevelError...
     noflines lfEotvos lgps_height  lorto_height lftiming_Meter lfTimingGPS  lfGPS_Corrections sampling;
% clear;
% CSigma;





