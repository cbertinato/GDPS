% Read my MeterProccesing.ini 
%

 % do things
  [file p] = uigetfile('p\*.*','Line LOg file file');
  log_fname=[p file] ;
 % save oldpath  p;
  % Now get the data   
fprintf('Readed Line log file %s \n',log_fname); 


 var={'Lines','hamon','numberoflines'};
 [nlines,b]=inifile(log_fname,'read',var);
 nlin=str2double(nlines);
 
 [Flights,Lnames,startline,endline] =textread(log_fname,['%s %s %s %s'],'delimiter',',','headerlines',3);
 
 
 
 
 

 
 
 

 
 