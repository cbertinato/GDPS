% compareLines,m
%Compare two lines and plot the difference


 line=1;  
 linelog1=cell2mat(lgpslong(:,line));
 linegpsacc1=cell2mat(lgpsacc(:,line));
 linelog2=cell2mat(lgpslong(:,line+1));
 linegpsacc2=cell2mat(lgpsacc(:,line+1));
 
 lineortho1=cell2mat(lorto_height(:,line));
 lineortho2=cell2mat(lorto_height(:,line+1));
 
 linegrav1=cell2mat(GravityFreeAir(:,line)); 
 linegrav2=cell2mat(GravityFreeAir(:,line+1)); 

 len=length(linelog2);


 Error=[];
 Errorg=[];
 Eortho=[];
 
 first=100;
last=len-1000;

 
for n=first:last
    
  I=find(linelog1 >= linelog2(n)); 
  
  e=linegpsacc2(n)-linegpsacc1(I(1));
  eg=linegrav2(n)-linegrav1(I(1));
  eortho=lineortho2(n)-lineortho1(I(1));
  
  Eortho=[Eortho eortho]; 
  Error=[Error e];  
  Errorg=[Errorg eg];
end 