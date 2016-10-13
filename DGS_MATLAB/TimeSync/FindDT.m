function dt = FindDT(lags,xc)

lags = lags(:);
xc = xc(:);
% [maxval,maxind]=max(abs(xc)); try this
[maxval,maxind]=max((xc));
dm1 = abs(xc(maxind) - xc(maxind-1));
dp1 = abs(xc(maxind) - xc(maxind+1));

if dm1 < dp1
    fit=polyfit(lags(maxind-2:maxind+1),xc(maxind-2:maxind+1),2);
else
    fit=polyfit(lags(maxind-1:maxind+2),xc(maxind-1:maxind+2),2);
end

dt = fit(2)/(2*fit(1));