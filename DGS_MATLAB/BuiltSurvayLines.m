% BuiltSurvay Lines
% Builts a cell arrays with all the survay lines
clear;
clc

id=1;
CC='Y';
while CC=='Y'
CC = inputdlg('Flight name?','Format',1,{'Flight'});
Flg = char(CC);  
load(Flg) 

fprintf('Added flight %s \n',Flg);


for n=1:noflines
 week{:,id} = lweek{:,n};
 weeksec{:,id} = lweeksec{:,n};
 T_Gravity{:,id}=Gravity{:,n};  
% T_Gravity{:,id}=lmeterPgrav{:,n}+lfGPS_Corrections{:,n}+lLevelError{:,n};
 T_GravityFreeAir{:,id}=GravityFreeAir{:,n}; 
 % T_GravityFreeAir_Final{:,id}=GravityFreeAir_Final{:,n};  % 
 
 
% T_GravityFreeAir{:,id}=lmeterPgrav{:,n}+lfGPS_Corrections{:,n}+lLevelError{:,n}+lfLatcorr{:,n}; %  calculate free air
 T_lfLatcorr{:,id}=lfLatcorr{:,n};
 T_lmeterPgrav{:,id}=lmeterPgrav{:,n};
 T_lfGPS_Corrections{:,id}=lfGPS_Corrections{:,n};
 
 T_lLevelError{:,id}=lLevelError{:,n};
%  T_legm{:,id}=legm{:,n};
 T_lgpsacc{:,id}=lgpsacc{:,n};
 T_lfEotvos{:,id}=lfEotvos{:,n};
 % cross couplings
 T_lvcc{:,id}=lvcc{:,n};
 T_lve{:,id}=lve{:,n};
 T_llc{:,id}=llc{:,n};
 T_lxc{:,id}=lxc{:,n};
 T_lax{:,id}=lax{:,n};
 T_lal{:,id}=lal{:,n};
 T_lmeter{:,id}=lmeter{:,n};
 T_lgpslong{:,id}=lgpslong{:,n};
 T_lgpslat{:,id}=lgpslat{:,n};
 T_lgps_height{:,id}=lgps_height{:,n};
 
 T_Lname{:,id}=Lname{:,n};
 T_Flight{:,id}=flight{:,n};
 T_status{:,id}=lstatus{:,n};
 T_lbeam{:,id}=lbeam{:,n};
 
 id=id+1;    
end
    
 Gravity=T_Gravity;  
 GravityFreeAir=T_GravityFreeAir; 
%Gravity=T_lmeterPgrav+T_lfGPS_Corrections+T_lLevelError;
lmeterPgrav=T_lmeterPgrav;
lfLatcorr=T_lfLatcorr;
 lgpslong=T_lgpslong;
 lgpslat=T_lgpslat;   
 lgps_height=T_lgps_height; 
%  legm=T_legm;
 lgpsacc=T_lgpsacc;
 lfEotvos=T_lfEotvos;
 lLevelError=T_lLevelError;
 lfGPS_Corrections=T_lfGPS_Corrections;
 lve=T_lve;
 lvcc=T_lvcc;
 lmeter=T_lmeter;
 lax=T_lax;
 lal=T_lal;
 llc=T_llc;
 lxc=T_lxc;
 
  Lname= T_Lname;
  Flight=T_Flight;
  lstatus=T_status;
  
 lbeam=T_lbeam;
 
CC = inputdlg('Add More Flight','Format',1,{'Y'});
CC = char(CC);

end
totallines=id-1;


 if(1==1)  
    
 save theSurvay weeksec week Gravity  GravityFreeAir llong lcross lve lvcc lfgpsacclong lfgpsacccross...
     lpress ltemp  lgpslong lgpslat lgpsacc lmeterPgrav lfLatcorr lLevelError...
     noflines lfEotvos lgps_height  lorto_height lftiming_Meter lfTimingGPS  lfGPS_Corrections sampling;   
    
  end 