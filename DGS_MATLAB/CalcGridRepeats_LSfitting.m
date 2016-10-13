 % Calculates Repeats in the of a grid of lines
%
% calculate the intersections

ToFile=1;

if ToFile==1
     [file p] = uiputfile('p\*.*','Load DGS file');
    fname=[p file] ;
    fid2 = fopen(fname,'a');
end

FixedLines=1;

 n = inputdlg('Filter length','Line',1,{'100'});
filtertime= str2num(char(n));

 filterlength=filtertime;    % 
 Taps=2*filterlength*sampling; % 
 B= fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 1 sec data
 

Mains=id-1;
intersec=zeros(Mains,Mains);
excluded=ones(Mains,1);
 excluded(16)=0; % T020
% excluded(35)=0; % F16
% excluded(36)=0;

 % filter lines to smoth
 


M=[];
M0=zeros(1,Mains);
  crossings=[];
   
 
e=[];
ve=[];
cal=[];
vcc=[];
metr=[];
za=[];
zxc=[];
zlc=[];
al=[];
ax=[];
ax2=[];
Ilong=[];
Icross=[];
st=[];
 
Index=[]; % index of the cross points
zz=0;
coco=1;
inter=0;

for n=1:Mains
        if excluded(n)==1  
         for m=Mains:-1:1
             if excluded(m)==1    
                 
            x1=cell2mat(lgpslong(:,n));
            y1=cell2mat(lgpslat(:,n));
            
         %   x1=filtfilt(B,1,lgpslong{:,n});
         %   y1=filtfilt(B,1,lgpslat{:,n});
            x1=x1(Taps:end-Taps);
            y1=y1(Taps:end-Taps);
            
            
           x2=cell2mat(lgpslong(:,m));
           y2=cell2mat(lgpslat(:,m));
           
         %   x2=filtfilt(B,1,lgpslong{:,m});
         %   y2=filtfilt(B,1,lgpslat{:,m});
             x2=x2(Taps:end-Taps);
             y2=y2(Taps:end-Taps);
            
            
              if intersec(m,n)~= 1 && m~=n  
                  
          %  [line1samp, line2samp] = FindLineIntersections(lgpslong{:,n},lgpslat{:,n},lgpslong{:,m},lgpslat{:,m});
             [line1samp, line2samp] = FindLineIntersections(x1,y1,x2,y2);
             
               
             ip1=round(line1samp);
             ip2=round(line2samp);
             
                 if ~isempty(line1samp)  % if lines intercep
                  inter=inter+1;   
                 crossings(n,m)=line1samp(1);
                    
             if FixedLines==1 
              Grav1= cell2mat(T_GravityFreeAir_Final(:,n));
              Grav2= cell2mat(T_GravityFreeAir_Final(:,m)); 
                 
             else   
              % Grav1=cell2mat(GravityFreeAir(:,n)); 
            Grav1=filtfilt(B,1,GravityFreeAir{:,n});
            Grav1=Grav1(Taps:end-Taps);
            
           % Grav2=cell2mat(GravityFreeAir(:,m));
             Grav2=filtfilt(B,1,GravityFreeAir{:,m});
            Grav2=Grav2(Taps:end-Taps);
             end
            
           % ve1=cell2mat(lve(:,n)); 
            ve1=filtfilt(B,1,lve{:,n});
            ve1=ve1(Taps:end-Taps);
           
           % ve2=cell2mat(lve(:,m)); 
            ve2=filtfilt(B,1,lve{:,m});
            ve2=ve2(Taps:end-Taps);
           
           % vcc1=cell2mat(lvcc(:,n)); 
            vcc1=filtfilt(B,1,lvcc{:,n});
            vcc1=vcc1(Taps:end-Taps);
                     
           % vcc2=cell2mat(lvcc(:,m)); 
            vcc2=filtfilt(B,1,lvcc{:,m});
            vcc2=vcc2(Taps:end-Taps);
           
           % meter1=cell2mat(lmeter(:,n));    % calibration
           meter1=filtfilt(B,1,lmeter{:,n});
           meter1=meter1(Taps:end-Taps);
           
           % meter2=cell2mat(lmeter(:,m));    % calibration
           
            meter2=filtfilt(B,1,lmeter{:,m});
            meter2=meter2(Taps:end-Taps);
            
            %za1=cell2mat(lLevelError(:,n));     % level monitor
            za1=filtfilt(B,1,lLevelError{:,n});
            za1=za1(Taps:end-Taps); 
            
          %  za2=cell2mat(lLevelError(:,m));     % level monitor
             za2=filtfilt(B,1,lLevelError{:,m});
            za2=za2(Taps:end-Taps); 
            
            
            zxc1=cell2mat(lxc(:,n));         %  cross acc monitor
            zxc2=cell2mat(lxc(:,m));         %  cross acc monitor
            zlc1=cell2mat(llc(:,n));         %  long accelerometer monitor
            zlc2=cell2mat(llc(:,m));         %  long accelerometer monitor
          
          flight1=T_Flight{:,n};
          flight2=T_Flight{:,m};
          line1=T_Lname{:,n};
          line2=T_Lname{:,m};  
                     
                     
                     
                     
                   g1=Grav1(ip1);
                    g2=Grav2(ip2); 
                     Ilong=[Ilong;x1(ip1)];
                     Icross=[Icross;y1(ip1)];
                     e=[e; g1-g2];
                     errorg=g1-g2;
                     
                     ve=[ve; ve1(ip1)-ve2(ip2)];
                     vcc=[vcc;  vcc1(ip1)-vcc2(ip2)];
                      metr=[metr;  meter1(ip1)-meter2(ip2)];  
                      za=[za;  za1(ip1)-za2(ip2)];
                  zxc=[zxc;  zxc1(ip1)-zxc2(ip2)];
                   zlc=[zlc;  zlc1(ip1)-zlc2(ip2)];
                                          
                      M=[M;M0];
                     M(coco,n)=1;
                     M(coco,m)=1;
                     coco=coco+1;
                                     
                 f1=char(flight1);
                  f2=char(flight2);
                  l1=char(line1);
                  l2=char(line2);
                  if ToFile==1
                      if abs(errorg) >= 5
                       
                         if abs(errorg) >= 10
                             if abs(errorg) >= 20
                               fprintf(fid2,'intersec %d %s %s line=%d %s %s line=%d  Error= %f !!!!!!!! \n',inter,f1,l1,n,f2,l2,m,errorg);   
                             else
                            fprintf(fid2,'intersec %d %s %s line=%d %s %s line=%d  Error= %f !!!! \n',inter,f1,l1,n,f2,l2,m,errorg); 
                             end
                         else
                         
                          fprintf(fid2,'intersec %d %s %s line=%d %s %s line=%d  Error= %f !! \n',inter,f1,l1,n,f2,l2,m,errorg);
                         end
                         
                         
                         
                      else
                        fprintf(fid2,'intersec %d %s %s line=%d %s %s line=%d  Error= %f \n',inter,f1,l1,n,f2,l2,m,errorg); 
                      end
                  end
                  if abs(errorg) >= 10
                   fprintf('intersec %d %s %s line=%d %s %s line=%d  Error= %f !!!!!!!!!!!!! \n',inter,f1,l1,n,f2,l2,m,errorg);    
                  else
                 fprintf('intersec %d %s %s line=%d %s %s line=%d  Error= %f \n',inter,f1,l1,n,f2,l2,m,errorg); 
                  end
                intersec(n,m)=1;
                end  
             
                     
                   
            end
        end
         end
    hold on; 
    
   % plot(x1(ip1),y1(ip1),':bs');
    
     plot(Ilong,Icross,'bs');
      
    end
end
% old off;
mycolor={'black','green','blue','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta'};


 for(l=1:id-1)
plot(lgpslong{:,l}, lgpslat{:,l}),title('Lat Long Position');
hold on
 end
legend(T_Lname{:,1})


MeanError=mean(abs(e));
fprintf('\n');
fprintf('Mean uncorrected Error %f \n',MeanError);
fprintf('\n');

% try to fit to improve data
dc=ones(length(e),1);

fit=2;

switch fit
         
 case 0
% ve vcc xc gain dc 

cc=[ve vcc metr dc];
mycoef=lscov(cc,-e);
P=mycoef;
ec=e+P(1)*ve+P(2)*vcc+P(3)*metr+P(4);

fprintf(' Correction factora\n');
fprintf('Ve= %f\n',P(1));
fprintf('vcc= %f\n',P(2));
fprintf('Gain= %f\n',P(3));
fprintf('DC= %f\n',P(4));

 case 1
% vcc Gain  level
 cc=[vcc metr za];
 mycoef=lscov(cc,-e);
P=mycoef;
ec=e+P(1)*vcc+P(2)*metr+P(3)*za;

fprintf(' Correction factora\n');

fprintf('Vcc= %f\n',P(1));
fprintf('Gain= %f\n',P(2));
fprintf('Level= %f\n',P(3));


case 2
% ve vcc  gain level dc 

cc=[ve vcc metr za dc];
mycoef=lscov(cc,-e);
P=mycoef;
ec=e+P(1)*ve+P(2)*vcc+P(3)*metr+P(4)*za+ P(5);

fprintf(' Correction factora\n');
fprintf('Ve= %f\n',P(1));
fprintf('vcc= %f\n',P(2));
fprintf('Gain= %f\n',P(3));
fprintf('level= %f\n',P(4));
fprintf('DC= %f\n',P(5));

case 3
% ve vcc  gain level xl xc dc 

cc=[ve vcc metr za zlc zxc dc];
mycoef=lscov(cc,-e);
P=mycoef;
ec=e+P(1)*ve+P(2)*vcc+P(3)*metr+P(4)*za+P(5)*zlc+P(6)*zxc+P(7);

fprintf(' Correction factora\n');
fprintf('Ve= %f\n',P(1));
fprintf('vcc= %f\n',P(2));
fprintf('Gain= %f\n',P(3));
fprintf('level= %f\n',P(4));
fprintf('lc= %f\n',P(5));
fprintf('xc= %f\n',P(6));
fprintf('DC= %f\n',P(7));

case 4 % DC line shift mode
    
mycoef=lscov(M,-e);   
P=mycoef;
ec=e+(M*P);

end



MeanError=mean(abs(ec));
mysigma=std(ec);



fprintf('\n');
fprintf('Mean Error corrected %f \n',MeanError);
fprintf('\n');

fprintf('Line corrected errors %f \n',ec);
fprintf('\n'); 
fprintf('Std = %f \n',mysigma);
fprintf('\n');
fprintf('\n');

fclose(fid2);
save CCGains P;


   
  
   
  
  
  
  
  


    
    
    
    
    
    
    
  