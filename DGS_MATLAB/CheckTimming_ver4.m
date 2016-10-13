% CheckTimming_Ver3 
% Check and Line the times from meter and gravity
n=noflines;

for line=1:n
    
 GPS=lfTimingGPS{:,line}; %  load gps acc
 METER=lftiming_Meter{:,line}; % Meter acceleration
 % get integer time offset between grav and GPS
 [xc,lags]=xcorr(METER,GPS,40);
[maxval,maxind]=max(abs(xc));
gravdt = -lags(maxind); % integer amount
dt=FindDT(lags,xc);

box = msgbox(sprintf('gravity time shift: %.3f sec',dt));
waitfor(box);


lmeterPgrav{:,line}=delayseq(lmeterPgrav{:,line},dt,1);
%llacc{:,line}=delayseq(llacc{:,line},dt,1);
%lxacc{:,line}=delayseq(lxacc{:,line},dt,1);
lve{:,line}=delayseq( lve{:,line},dt,1);
lvcc{:,line}=delayseq(lvcc{:,line},dt,1);
lal{:,line}=delayseq( lal{:,line},dt,1);
lax{:,line}=delayseq(lax{:,line},dt,1);
%lax2{:,line}=delayseq(lax2{:,line},dt,1);
%lal2{:,line}=delayseq(lal2{:,line},dt,1);

%linePgrav{:,line}=lmeterPgrav{:,line}+lGPStotalacc{:,line}+gravitymeteroffset;
% linePgrav{:,line}=lmeterPgrav{:,line}+lGPStotalacc{:,line};


% find the delays after


 METER=delayseq(METER,dt,1);

 
 % get integer time offset between grav and GPS
 [xc,lags]=xcorr(METER,GPS,40);
[maxval,maxind]=max(abs(xc));
gravdt = -lags(maxind); % integer amount
dt=FindDT(lags,xc);

box = msgbox(sprintf('gravity time shift: %.3f sec',dt));
waitfor(box);
 

linePgrav{:,line}= lmeterPgrav{:,line}+lfGPS_Corrections{:,line}; % recompute corrected grav

end

save thelines linePgrav  lve lvcc lal lax ...
     lpress ltemp  lgpslong lgpslat lgpsacc lmeterPgrav lfLatcorr lLevelError...
     noflines lfEotvos lgps_height  lorto_height lftiming_Meter lfTimingGPS  lfGPS_Corrections sampling;
