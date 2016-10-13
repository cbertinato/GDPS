 % Calculates Repeats in the of a grid of lines
%
% calculate the intersections

Mains=10;
Crosses=2;
e=[];
ve=[];
cal=[];
vcc=[];
al=[];
ax=[];
ax2=[];
Ilong=[];
Icross=[];
st=[];

Index=[]; % index of the cross points
zz=0;

for n=1:Mains
    for m=Mains+1:Mains+Crosses
    x1=cell2mat(lgpslong(:,n));
    y1=cell2mat(lgpslat(:,n));
    x2=cell2mat(lgpslong(:,m));
    y2=cell2mat(lgpslat(:,m));
    
   Grav1=cell2mat(GravityFreeAir(:,n)); 
   Grav2=cell2mat(GravityFreeAir(:,m));
   
    
    if(1==0)
    ve1=cell2mat(lve(:,n)); 
    ve2=cell2mat(lve(:,m)); 
    cal1=cell2mat(lBveloc(:,n)); 
    cal2=cell2mat(lBveloc(:,m)); 
    vcc1=cell2mat(lvcc(:,n)); 
    vcc2=cell2mat(lvcc(:,m)); 
    al1=cell2mat(lal(:,n)); 
    al2=cell2mat(lal(:,m)); 
    aax1=cell2mat(lax(:,n)); 
    aax2=cell2mat(lax(:,m)); 
    ax21=cell2mat(lax2(:,n)); 
    ax22=cell2mat(lax2(:,m)); 
    st1=cell2mat(lST(:,n)); 
    st2=cell2mat(lST(:,m)); 
    end
    [line1samp, line2samp] = FindLineIntersections(lgpslong{:,n},lgpslat{:,n},lgpslong{:,m},lgpslat{:,m});
    ip1=round(line1samp);
    ip2=round(line2samp);
    g1=Grav1(ip1);
    g2=Grav2(ip2);
    
    Ilong=[Ilong;x1(ip1)];
    Icross=[Icross;y1(ip1)];
    
    e=[e g1-g2];
    if(1==0)
    ve=[ve ve1(ip1)-ve2(ip2)];
    cal=[cal cal1(ip1)-cal2(ip2)];
    vcc=[vcc vcc1(ip1)-vcc2(ip2)];
    al=[al al1(ip1)-al2(ip2)];
    ax=[ax aax1(ip1)-aax2(ip2)];
    ax2=[ax2 ax21(ip1)-ax22(ip2)];
    st=[st st1(ip1)-st2(ip2)];
    end
    
    hold on; 
    plot(x1(ip1),y1(ip1),':bs');
    plot(x2(ip2),y2(ip2),':bs');
    
    end
end
% hold off;
mycolor={'black','green','blue','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow'};
 for(l=1:id-1)
plot(lgpslong{:,l}, lgpslat{:,l},mycolor{:,l}),title('Lat Long Position');
hold on
 end




MeanError=mean(abs(e));
fprintf('\n');
fprintf('Mean Error %f \n',MeanError);
fprintf('\n');
fprintf('Line errors %f \n',e);






    
   
  
   
  
  
  
  
  


    
    
    
    
    
    
    
  