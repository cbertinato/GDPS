% corsetimeshift.m
 [xc,lags]=xcorr(-METER,GPS,1000);
plot(lags,xc)