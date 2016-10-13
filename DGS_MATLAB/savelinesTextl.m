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
d = {'Lattitude','Longitude','gps heigth','orto height','Gravity','Free-Air','EGM08'};
warning off MATLAB:xlswrite:AddSheet
% xlswrite(fname,d,sheetname);
A=[lgpslat{:,l} lgpslong{:,l} lgps_height{:,l} lorto_height{:,l} Gravity{:,l} GravityFreeAir{:,l} legm{:,l}];
xlswrite(fname,A,sheetname);
end

for l=1:n
    line=num2str(l);
 sheetname = ['L' line];   
 xlswrite(fname,d,sheetname);   

end

 deleteEmptyExcelSheets(fname);