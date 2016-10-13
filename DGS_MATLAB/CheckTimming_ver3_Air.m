% CheckTimming_Ver3_Air 
% Finds the optimun time shift between Mter gravity and GPS vertical
% acceleration, by achieveing maximum correlation between both signals

MaxShift=20;
LSTimming=0; % use of LS minimization for time
% load thelines
line=noflines-n+1;
Pr=1;

for h=1:n
    
 GPS=lfTimingGPS{:,line}; %  load gps acc
 METER=lftiming_Meter{:,line}; % Meter acceleration
 
 % get integer time offset between grav and GPS
 [xc,lags]=xcorr(-METER,GPS,MaxShift);
%[maxval,maxind]=max(abs(xc));
% figure
% plot(lags,xc)

dt=FindDT(lags,xc);
dtime(h)=dt/sampling; % store the time dalays for each line
dj(h)=h;

box = msgbox(sprintf('gravity time shift: %.3f sec',dt/sampling));
waitfor(box);

dt2=NLinearTimeSync(dt,-METER,GPS);
dtime2(h)=dt2;


% mdt=CheckTimmingNL_LS(METER,GPS,dt);

 METER=FTPhaseShift(METER,dt,1);
% get integer time offset between grav and GPS
 [xc,lags]=xcorr(-METER,GPS,MaxShift);
% [maxval,maxind]=max(abs(xc));
% gravdt = -lags(maxind); % integer amount
dt=FindDT(lags,xc);

% box = msgbox(sprintf('gravity time shift: %.3f sec',dt/sampling));
% waitfor(box);

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
 box = msgbox(sprintf('shifting gravity time: %.3f sec',dt));
waitfor(box);
 end
 line=noflines-n+1;
 
 dt=10*dt;
 
for h=1:n
    
 if  Allsync=='N'
 
lmeterPgrav{:,line}=FTPhaseShift(lmeterPgrav{:,line},dt,Pr);
lmeterg{:,line}=FTPhaseShift(lmeterg{:,line},dt,Pr);

llong{:,line}=FTPhaseShift(llong{:,line},dt,Pr);
lcross{:,line}=FTPhaseShift(lcross{:,line},dt,Pr);
lve{:,line}=FTPhaseShift(lve{:,line},dt,Pr);
lvcc{:,line}=FTPhaseShift( lvcc{:,line},dt,Pr);

llc{:,line}=FTPhaseShift(llc{:,line},dt,Pr);
lxc{:,line}=FTPhaseShift( lxc{:,line},dt,Pr);
lax{:,line}=FTPhaseShift(lax{:,line},dt,Pr);
lal{:,line}=FTPhaseShift( lal{:,line},dt,Pr);
lmeter{:,line}=FTPhaseShift(lmeter{:,line},dt,Pr);

%lx2{:,line}=FTPhaseShift(lx2{:,line},dt,1);
%lax2{:,line}=FTPhaseShift(lax2{:,line},dt,1);
%lal2{:,line}=FTPhaseShift(lal2{:,line},dt,1);
%linePgrav{:,line}=lmeterPgrav{:,line}+lGPStotalacc{:,line}+gravitymeteroffset;
%linePgrav{:,line}=lmeterPgrav{:,line}+lGPStotalacc{:,line};
% find the delays after

 else
lmeterPgrav{:,line}=FTPhaseShift(lmeterPgrav{:,line},dtime(h),Pr);
lmeterg{:,line}=FTPhaseShift(lmeterg{:,line},dtime(h),Pr);

llong{:,line}=FTPhaseShift(llong{:,line},dtime(h),Pr);
lcross{:,line}=FTPhaseShift(lcross{:,line},dtime(h),Pr);
lve{:,line}=FTPhaseShift( lve{:,line},dt,Pr);
lvcc{:,line}=FTPhaseShift( lvcc{:,line},dt,Pr);

llc{:,line}=FTPhaseShift(llc{:,line},dt,Pr);
lxc{:,line}=FTPhaseShift( lxc{:,line},dt,Pr);
lax{:,line}=FTPhaseShift(lax{:,line},dtime(h),Pr);
lal{:,line}=FTPhaseShift(lal{:,line},dtime(h),Pr);
lmeter{:,line}=FTPhaseShift(lmeter{:,line},dtime(h),Pr);

%lx2{:,line}=FTPhaseShift(lx2{:,line},dtime(h),1);

 end

%  mdt=CheckTimmingNL_LS(METER,GPS,dt);
 switch Levelcorr
     case 0 
      fprintf('\n');
      fprintf('No level correction \n');
    Gravity{:,line}= lmeterPgrav{:,line}+lfGPS_Corrections{:,line}; % recompute full field gravity
    GravityFreeAir{:,line}=lmeterPgrav{:,line}+lfGPS_Corrections{:,line}+lfLatcorr{:,line}; %  calculate free air
     
     case 1 
      LevelGain=1.5;
     fprintf('\n');
      fprintf('Level correction \n');    
    Gravity{:,line}= lmeterPgrav{:,line}+lfGPS_Corrections{:,line}+LevelGain*lLevelError{:,line}; % recompute full field gravity
    GravityFreeAir{:,line}=lmeterPgrav{:,line}+lfGPS_Corrections{:,line}+LevelGain*lLevelError{:,line}+lfLatcorr{:,line}; %  calculate free air
 end
 line=line+1; 
end

if(1==1) % save corrected lines
save thelines Gravity  GravityFreeAir lmeterPgrav  lmeterg  llong lcross lve lvcc lax lal llc lxc lmeter lbeam lfgpsacclong lfgpsacccross...
     lpress ltemp  lgpslong lgpslat lgpsacc lfLatcorr lLevelError flight Lname lweek lweeksec...
     noflines lfEotvos lgps_height  lorto_height lftiming_Meter lfTimingGPS TideGravity PreTieReading lfGPS_Corrections sampling lstatus;
end



