 % QC_Process.m


ReadfilesAT1A2      % read files in AT1A format
uiwait(msgbox('Load GPS file','Message','none'))
ReadGPS2_Airborne   % Read the GPS exported file in DGS format
LineupdataAirborne  % Line on time the GPS and Meter data using the time sfiletamp
uiwait(msgbox('Make lines','Mess age','none'))
ReadLineLog         % Read nlin Lnames,startline,endline from fligth 
MakeLinesAirborne   % Make lines from grafic input
% MakeLinesAirFromLog % Make lines from flight log times
CheckTimming_ver3_Air % Perform fine time synchronization
% iterativePlotFixlines 
% Plotbylines
% ExportFlight    % Export lines to a text format file