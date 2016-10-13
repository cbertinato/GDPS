clear
[file p] = uigetfile('p\*.*','Load DGS file');
  fname=[p file] ;
  
  in=ReadAT1A(fname);
  
  dat.gravity=decimate(in.gravity,10);
  dat.long=decimate(in.long,10);
  dat.cross=decimate(in.cross,10);
  dat.beam=decimate(in.beam,10);
  dat.temp=decimate(in.temp,10);
  dat.press=decimate(in.pressure,10);
  dat.Etemp=decimate(in.Etemp,10);
  dat.status=downsample(in.status,10);
  
  
  % dat.GPSWeek=[dat.GPSWeek;in.GPSweek];
  % dat.WeekSeconds=[dat.WeekSeconds;in.Weekseconds];

  l=length(dat.gravity);
  Non=zeros(l,1);

  
  


csvwrite('datadecimated.csv',[Non dat.gravity dat.long dat.cross dat.beam dat.status Non dat.press dat.Etemp Non Non Non Non Non Non Non Non Non Non Non Non Non Non]);