function meterdata=ReadAT1M(fname)
% reads AT1M.dat file
%
% [QCgravity,gravity,long,cross,beam,temp,status,checksum,pressure
% ,Etemp,ve,vcc,al,ax,latitude,longitude,speed,course,vmond,Y,M,D,h,m,s]=ReadAT1M(fname)
%
% fname: AT1M file name
%
% meterdata: AT1M data structure
% meterdata.QCgravity: Meter QC gravity
% meterdata.gravity: raw gravity
% meterdata.long: long accelerometer in Gal
% meterdata.cross: cross accelerometer in Gals
% meterdata.temp: meter temp
% meterdata.beam: Beam position 
% meterdata.status: status integer
% meterdata.checksum: check sum
% meterdata.pressure: meter pressure
% meterdata.Etemp: electronics temperature
% meterdata.ve: ve monitor
% meterdata.vcc: vcc monitor
% meterdata.al: al monitor
% meterdata.al: ax monitor
% meterdata.latitude: latitude degress
% meterdata.longitude: longitude degress
% meterdata.speed: speed knots
% meterdata.course: north heading degress
% meterdata.vmond: average vertical velocity
% meterdata.Y: Year
% meterdata.M: Month
% meterdata.D: Day
% meterdata.h: hours
% meterdata.m: minutes
% meterdata.s: seconds



[QCgravity,gravity,long,cross,beam,temp,status,checksum,pressure,Etemp,ve,vcc,al,ax,latitude,longitude,speed,course,vmond,Y,M,D,h,m,s]=...
textread(fname,['%f %f %f %f %f %f %d %f %f %f %f %f %f %f %f %f %f %f %f %d %d %d %d %d %f %*[^\n]'],'delimiter',',');

  
 meterdata.QCgravity=QCgravity;
 meterdata.gravity=gravity;
 meterdata.long=long;
 meterdata.cross=cross;
 meterdata.temp=temp;
 meterdata.beam=beam; 
 meterdata.status=status;
 meterdata.checksum=checksum;
 meterdata.pressure=pressure;
 meterdata.Etemp=Etemp;
 meterdata.ve=ve;
 meterdata.vcc=vcc;
 meterdata.al=al;
 meterdata.ax=ax;
 meterdata.latitude=latitude;
 meterdata.longitude=longitude;
 meterdata.speed=speed;
 meterdata.course=course;
 meterdata.vmond=vmond;
 meterdata.Y=Y;
 meterdata.M=M;
 meterdata.D=D;
 meterdata.h=h;
 meterdata.m=m;
 meterdata.s=s;



end

