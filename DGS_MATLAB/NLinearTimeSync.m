function time=NLinearTimeSync(t0,meter,gps)

options = optimset('Display','none');
lsdt=lsqnonlin(@(x) FTPhaseShift(meter,x,1)-gps,t0,-1,1,options);

% box=msgbox(sprintf('ths LS optimun time shitf is %+6.3f s',lsdt));
%waitfor(box);

time=lsdt;

end




    
