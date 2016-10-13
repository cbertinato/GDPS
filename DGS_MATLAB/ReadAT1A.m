function meterdata=ReadAT1A(fname)
% reads AT1M.dat file


[gravity,long,cross,beam,temp,status,pressure,Etemp,GPSweek,Weekseconds]=...
textread(fname,['%f %f %f %f %f %f %f %f %f %f %*[^\n]'],'delimiter',',');

  
 meterdata.gravity=gravity;
 meterdata.long=long;
 meterdata.cross=cross;
 meterdata.temp=temp;
 meterdata.beam=beam; 
 meterdata.status=status;
 meterdata.pressure=pressure;
 meterdata.Etemp=Etemp;

 meterdata.GPSweek=GPSweek;
 meterdata.Weekseconds=Weekseconds;

end

