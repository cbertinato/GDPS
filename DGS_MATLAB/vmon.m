function fvmon=vmon(sec,gravity)
% calculates de vmon monitor for a AT1M meter
% Autor Daniel Aliod % September 2014
% fvmon=filtered mean absolute vertical velocity in cm/sec
% sec= filter aplayed to vmon
% gravity=raw gravity

 %----------------------------------------------------
 vmonTap=60;
 vmonB= fir1(vmonTap,1/vmonTap,blackman(vmonTap+1));
 % --------------------------------------------------
 f60grav=filter(vmonB,1,gravity);   % filter for for remove the mean
 f60grav=f60grav(vmonTap/2:end);
 
 % -------------------------------------------------------
 Taps=2*sec; % 
 B = fir1(Taps,1/Taps,blackman(Taps+1));
 % ------------------------------------------------------
 
rawgravity=gravity(1:length(f60grav));

I=cumsum(rawgravity-f60grav);
vmo=abs((I-mean(I))/1000);
fvmon=filter(B,1,vmo); % mean vertical velocity cm/sec   
fvmon=fvmon(Taps/2:end);

% plot(fvmon);

end