% CheckTimming_Ver3 
% Finds the optimun time shift between Mter gravity and GPS vertical
% acceleration, by achieveing maximum correlation between both signals

MaxShift=20;
LSTimming=1; % use of LS minimization for time
% load thelines
line=noflines-n+1;

for h=1:n
    
 GPS=lfTimingGPS{:,line}; %  load gps acc
 METER=lftiming_Meter{:,line}; % Meter acceleration
 
 % get integer time offset between grav and GPS
 [xc,lags]=xcorr(METER,GPS,MaxShift);
[maxval,maxind]=max(abs(xc));



dt=FindDT(lags,xc);
dtime(h)=dt % store the time dalays for each line
dj(h)=h;

box = msgbox(sprintf('gravity time shift: %.3f sec',dt/sampling));
waitfor(box);

dt2=NLinearTimeSync(dt,-METER,GPS);
dtime2(h)=dt2;


% mdt=CheckTimmingNL_LS(METER,GPS,dt);

 METER=FTPhaseShift(METER,dt,1);
% get integer time offset between grav and GPS
 [xc,lags]=xcorr(METER,GPS,MaxShift);
[maxval,maxind]=max(abs(xc));
gravdt = -lags(maxind); % integer amount
dt=FindDT(lags,xc);

box = msgbox(sprintf('gravity time shift: %.3f sec',dt/sampling));
waitfor(box);

% check againg


line=line+1;
end


CC = inputdlg('Shift by line Y or All the lines N?','Selec time Sync',1,{'N'});
Allsync = char(CC);
 
if LSTimming==1
  dtime=dtime2; % use LS time 
end

 if  Allsync=='N'
dt=mean(dtime);  
 box = msgbox(sprintf('shifting gravity time: %.3f sec',dt/sampling));
waitfor(box);
 end


line=noflines-n+1;
for h=1:n
    
 if  Allsync=='N'
 
 
lmeterPgrav{:,line}=FTPhaseShift(lmeterPgrav{:,line},dt,1);
llong{:,line}=FTPhaseShift(llong{:,line},dt,1);
lcross{:,line}=FTPhaseShift(lcross{:,line},dt,1);
lve{:,line}=FTPhaseShift( lve{:,line},dt,1);
lvcc{:,line}=FTPhaseShift(lvcc{:,line},dt,1);
lal{:,line}=FTPhaseShift( lal{:,line},dt,1);
lax{:,line}=FTPhaseShift(lax{:,line},dt,1);
ll2{:,line}=FTPhaseShift( ll2{:,line},dt,1);
lx2{:,line}=FTPhaseShift(lx2{:,line},dt,1);
%lax2{:,line}=FTPhaseShift(lax2{:,line},dt,1);
%lal2{:,line}=FTPhaseShift(lal2{:,line},dt,1);
%linePgrav{:,line}=lmeterPgrav{:,line}+lGPStotalacc{:,line}+gravitymeteroffset;
%linePgrav{:,line}=lmeterPgrav{:,line}+lGPStotalacc{:,line};
% find the delays after

 else
lmeterPgrav{:,line}=FTPhaseShift(lmeterPgrav{:,line},dtime(h),1);
llong{:,line}=FTPhaseShift(llong{:,line},dtime(h),1);
lcross{:,line}=FTPhaseShift(lcross{:,line},dtime(h),1);
lve{:,line}=FTPhaseShift( lve{:,line},dtime(h),1);
lvcc{:,line}=FTPhaseShift(lvcc{:,line},dtime(h),1);
lal{:,line}=FTPhaseShift( lal{:,line},dtime(h),1);
lax{:,line}=FTPhaseShift(lax{:,line},dtime(h),1);
ll2{:,line}=FTPhaseShift(ll2{:,line},dtime(h),1);
lx2{:,line}=FTPhaseShift(lx2{:,line},dtime(h),1);

 end

%  mdt=CheckTimmingNL_LS(METER,GPS,dt);

 linePgrav{:,line}= lmeterPgrav{:,line}+lfGPS_Corrections{:,line}; % recompute corrected grav

 line=line+1; 
end
if(1==0) % save corrected lines
save thelines linePgrav  llong lcross lve lvcc lal lax lfgpsacclong ll2 lx2  lfgpsacccross...
     lpress ltemp  lgpslong lgpslat lgpsacc lmeterPgrav lfLatcorr lLevelError...
     noflines lfEotvos lgps_height  lorto_height lftiming_Meter lfTimingGPS  lfGPS_Corrections sampling;
end
