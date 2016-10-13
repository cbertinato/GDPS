function meterdata=ReadAirborne(fname)
% reads AT1M.dat file


[gravity,long,cross,beam,temp,pressure,Etemp,status,latitude,longitude,GPSweek,weekseconds]=...
textread(fname,['%f %f %f %f %f %f %f %f %f %f %f %f %*[^\n]'],'delimiter',',');

  
 meterdata.gravity=gravity;
 meterdata.long=long;
 meterdata.cross=cross;
 meterdata.temp=temp;
 meterdata.beam=beam; 
 meterdata.status=status;
 meterdata.pressure=pressure;
 meterdata.Etemp=Etemp;
 meterdata.latitude=latitude;
 meterdata.longitude=longitude;
 meterdata.GPSweek=GPSweek;
 meterdata.Weekseconds=Weekseconds;

end

