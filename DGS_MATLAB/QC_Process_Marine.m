 % QC_ProcessMarine.m


ReadfilesAT1M2      % read files inDGS Marine format 
uiwait(msgbox('Load GPS file','Message','none'))
ReadGPS2  % Read the GPS exported file in DGS format at 1 hz
Lineupdata % Line on time the GPS and Meter data using the time sfiletamp
uiwait(msgbox('Make lines','Mess age','none'))
ReadLineLog         % Read nlin Lnames,startline,endline from fligth 
MakeLines  % Make lines from grafic input
% MakeLinesAirFromLog % Make lines from flight log times
CheckTimming_ver3 % Perform fine time synchronization
% iterativePlotFixlines 
% Plotbylines
% ExportFlight    % Export lines to a text format file