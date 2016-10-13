% Read my MeterProccesing.ini 
%

 % do things
  [file p] = uigetfile('p\*.*','Process configuration file');
  config_fname=[p file] ;
 % save oldpath  p;
  % Now get the data   
fprintf('Readed proceesing configuration file %s \n',config_fname); 


  var={'Sensor','hamon','Meter'};
 [Meter,b]=inifile(config_fname,'read',var);
 
 var={'Sensor','hamon','timeshift'};
 [timeshift,b]=inifile(config_fname,'read',var);
 sensortime=cell2mat(timeshift);
 
 var={'Sensor','hamon','filtertime'};
 [filtertime,b]=inifile(config_fname,'read',var);
 filtertime=cell2mat(filtertime);
 
 var={'Sensor','hamon','filtype'};
 [filtype,b]=inifile(config_fname,'read',var);
 filtertype=cell2mat(filtype);
 
 var={'Sensor','hamon','levelcorrection'};
 [levelcorrection,b]=inifile(config_fname,'read',var);
 Levelcorr=cell2mat(levelcorrection);
 
 
 var={'Sensor','hamon','kfactor'};
 [gravitycal,b]=inifile(config_fname,'read',var);
 kfactor=cell2mat(gravitycal);
 
 var={'Survay','hamon','PreStill'};
 [PreStill,b]=inifile(config_fname,'read',var);
 PreStillReading=cell2mat(PreStill);
 
 var={'Survay','hamon','PostStill'};
 [PostStill,b]=inifile(config_fname,'read',var);
 PosStillReading=cell2mat(PostStill);
 
 var={'Survay','hamon','TieGravity'};
 [TieGravity,b]=inifile(config_fname,'read',var);
 Tieg=cell2mat(TieGravity);
 
  var={'crosscouplings','hamon','vcc'};
 [vcc,b]=inifile(config_fname,'read',var);
 vcc_comp=cell2mat(vcc);
 
 var={'crosscouplings','hamon','ve'};
 [ve,b]=inifile(config_fname,'read',var);
 ve_comp=cell2mat(ve);
 
  var={'crosscouplings','hamon','lc'};
 [lc,b]=inifile(config_fname,'read',var);
 lc_comp=cell2mat(lc);
 
  var={'crosscouplings','hamon','xc'};
 [xc,b]=inifile(config_fname,'read',var);
 xc_comp=cell2mat(xc);
 
   var={'crosscouplings','hamon','monitors'};
 [monitors,b]=inifile(config_fname,'read',var);
 monitors_comp=cell2mat(monitors);
 
 
 

 
 
 

 
 