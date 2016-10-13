% ReadRawSensor.m
% Reads the Raw sensor data


[file p] = uigetfile('p\*.*','Load sensor Raw data');
  fname=[p file] ;

[lineheading,gravity,long,cross,beam,temp,pressure,Etemp,status,latitude,longitude,GPSweek,weekseconds]=...
textread(fname,['%s %s %s %s %s %s %s %s %s %s %s %s %s %*[^\n]'],'delimiter',',');



format long 
%numberofsamples=length(gravity)/10-0.1
%metertime=(weekseconds(end)-weekseconds(1))
%diff=numberofsamples-metertime