% builtin
x=3000;
y=4000;
s=gpsacc(x:y);
in=timeseries(s);

MaxShift=20;

METER=in.Data+100*rand(length(s),1)+10000;
GPS=s;

[xc,lags]=xcorr(METER,GPS,MaxShift);
dt=FindDT(lags,xc);

 dt2=NLinearTimeSync(dt,METER,GPS);
 
  plot(GPS-METER)