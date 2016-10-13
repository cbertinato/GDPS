% ---------------------------
% saveexcel.m
% ---------------------------
% save lines in excel compatible format
%
% Daniel Aliod

[file p] = uiputfile('p\*.*','Process configuration file');
 fname=[p file] ;

% fname=uiputfile;


for l=1:n
line=num2str(l);
sheetname = ['L' line];    
d = {'Lattitude','Longitude','gps heigth','orto height','Gravity','Free-Air','EGM08','gpsweek','weekseconds'};
warning off MATLAB:xlswrite:AddSheet
% xlswrite(fname,d,sheetname);
A=[lgpslat{:,l} lgpslong{:,l} lgps_height{:,l} lorto_height{:,l} Gravity{:,l} GravityFreeAir{:,l} legm{:,l} lweek{:,l} lweeksec{:,l}];

N1=decimate(lgpslat{:,l},10);
N2=decimate(lgpslong{:,l},10); 
N3=decimate(lgps_height{:,l},10);
N4=decimate(lorto_height{:,l},10); 
N5=decimate(Gravity{:,l},10);
N6=decimate(GravityFreeAir{:,l},10);
N7=decimate(legm{:,l},10);
N8=downsample(lweek{:,l},10);
N9=downsample(lweeksec{:,l},10);
AD=[N1 N2 N3 N4 N5 N6 N7 N8 N9];
xlswrite(fname,AD,sheetname);
end

for l=1:n
    line=num2str(l);
 sheetname = ['L' line];   
 xlswrite(fname,d,sheetname);   

end

 deleteEmptyExcelSheets(fname);