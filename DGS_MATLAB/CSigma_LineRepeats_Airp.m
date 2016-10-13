 % Calculates the sigma of a group of lines
% and prepares 
filtertype=0;  
% load thelin
n=totallines;

ntaps = inputdlg('Filter length','Line',1,{'100'});
filtertime= str2num(char(ntaps));

filterlength=filtertime;    % 
Taps=2*filterlength*sampling; % 
B= fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 1 sec data
 
LineSeparation=0.005;
RepeatFreq=3;      % 1 for airplane For  6 for van
% find the shorter line line 
maxlong=2000;
minlong=-2000;
for l=1:n                       % find maximun and minimyn longitude.
% lo1=cell2mat(lgpslong(:,l));    % if test line is shorter than all other lines
 
 lo1=filtfilt(B,1,lgpslong{:,l}); % % longitude of current line
 lo1=lo1(Taps:end-Taps);  
 
M=max(lo1);                     % the intersection with each lina will have the same length
m=min(lo1);
if(M<maxlong)
    maxlong=M;
end
if(m>minlong)
    minlong=m;
end    
end

% log=cell2mat(lgpslong(:,1));   % load the first line
log=filtfilt(B,1,lgpslong{:,1}); % % longitude of current line
log=log(Taps:end-Taps);  

% ltg=cell2mat(lgpslat(:,1));

ltg=filtfilt(B,1,lgpslat{:,1}); % % latitude of current line
 ltg=ltg(Taps:end-Taps);  


coef=polyfit(log,ltg,1);       % calculate the slope of first line
inc=(maxlong-minlong)/length(log)*sampling;
blong=(minlong:inc:maxlong);
blat=coef(1)*blong+coef(2); % make a line with same slope but shorter

dx=blong(end)-blong(1); % 
dy=blat(end)-blat(1);
alfa=atan2(dy,dx);

base=(1:length(blat));          % generate the sin test signal
dlat=LineSeparation*cos(base/RepeatFreq);
dlong=zeros(1,length(dlat));

 dlong=dlong*sin(-alfa);    % rottate the test signal 
 dlat=dlat*cos(-alfa);

log=blong+dlong;
ltg=blat+dlat;              

% % plot all the lines
mycolor={'black','green','blue','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow'};
% mycolor={'-k.','-g.','-b.','-c.','-r.','-m.','-y.','-k.','-g.','-b.','-c.','-r.','-m.','-y.'};
mycolor2={'k','g','b','c','r','m','y','k','g','b','c','r','m','k'};
% PlotPosition
% axis equal on

% plot lines and test line
figure
hold on;
 for l=1:n
plot(111197*lgpslong{:,l}.*cos(pi*lgpslat{:,l}/180),111197* lgpslat{:,l},mycolor2{:,l}),title('Line repeats');
 end
 plot(111197*log.*cos(pi* ltg/180),111197* ltg);
 pause;
 hold off;
 close;

 ln=[1 2 3 4 5 6 7 8 10 11 12 13];

cg=0;
cfg=0;
cve=0;
cvcc=0;
cax=0;
cal=0;
cvcc=0;


for q=1:n   
 if filtertype==0  
     
  mg=filtfilt(B,1,lmeter{:,q}); % meter gravity no offset
  mg= mg(Taps:end-Taps);
  
  mabsg=filtfilt(B,1,lmeterPgrav{:,q}); % meter absolute gravity n
  mabsg=mabsg(Taps:end-Taps); 
  
 else
     
  ns=length(GravityFreeAir{:,l}); 
   mt=0:0.1:ns/10-1;
   mg=gaussian_filter(mt,lmeter{:,q},filtertime,3);
   mabsg=gaussian_filter(mt,lmeterPgrav{:,q},filtertime,3); 
   mg= mg(Taps:end-Taps);
   mg=mg';
   mabsg=mabsg(Taps:end-Taps);
   mabsg=mabsg';
     
 end   
  
  lc=filtfilt(B,1,llc{:,q}); %
  lc=lc(Taps:end-Taps);  
 xc=filtfilt(B,1,lxc{:,q}); %
 xc=xc(Taps:end-Taps);  
 vcc=filtfilt(B,1,lvcc{:,q}); %
 vcc=vcc(Taps:end-Taps);  
 ve=filtfilt(B,1,lve{:,q}); %
 ve=ve(Taps:end-Taps); 
 al=filtfilt(B,1,lal{:,q}); %
 al=al(Taps:end-Taps); 
 ax=filtfilt(B,1,lax{:,q}); %
 ax=ax(Taps:end-Taps); 
% drift=cell2mat(ldrift(:,q));
 lo2=filtfilt(B,1,lgpslong{:,q}); % % longitude of current line
 lo2=lo2(Taps:end-Taps);  
 lt2=filtfilt(B,1,lgpslat{:,q}); % % latitude of current line
 lt2=lt2(Taps:end-Taps);  
 gacc=filtfilt(B,1,lgpsacc{:,q});
 gacc=gacc(Taps:end-Taps);
 eotvos=filtfilt(B,1,lfEotvos{:,q});
 eotvos=eotvos(Taps:end-Taps);  
 level=filtfilt(B,1,lLevelError{:,q});
 level=level(Taps:end-Taps);  
 latcorr=filtfilt(B,1,lfLatcorr{:,q});
 latcorr=latcorr(Taps:end-Taps);  
 egm=filtfilt(B,1,legm{:,q});
 egm=egm(Taps:end-Taps);  
%  GPStotal=cell2mat(lGPStotalacc_OnSensor(:,q));
 GPStotal=filtfilt(B,1,lfGPS_Corrections{:,q});
 GPStotal=GPStotal(Taps:end-Taps);
 
% totg=mg+eotvos-gacc-latcorr-freeair-level;
% totg=mg+GPStotal-level; %+gravitymeteroffset;
% totg=mg+GPStotal+level-tide; %+gravitymeteroffset;

if filtertype==0

totg=filtfilt(B,1,T_GravityFreeAir{:,q});
totg=totg(Taps:end-Taps);  
% totg=totg+vcc;
fullfield=filtfilt(B,1,T_Gravity{:,q});
fullfield=fullfield(Taps:end-Taps);  
%fullfield=fullfield-0.5*vcc;
else
 
 ns=length(GravityFreeAir{:,l}); 
   mt=0:0.1:ns/10-1;
   totg=gaussian_filter(mt,T_GravityFreeAir{:,q},filtertime,3);
   totg=totg(Taps:end-Taps); 
   totg=totg';
   fullfield=gaussian_filter(mt,T_Gravity{:,q},filtertime,3); 
   fullfield=fullfield(Taps:end-Taps);  
    fullfield=fullfield';  
    
end    
    

% totg=totg-GPStotal;

[line1samp, line2samp] = FindLineIntersections(log,ltg,lo2,lt2); % log and ltg are the generated 
 ip2=round(line2samp);
 
 lines.ln(q).x=ip2;                 % store the index of the intersection in a structure
 lines.ln(q).g=totg(ip2);           % store the  free air g values at the intersection in a structure data
 lines.ln(q).fullg=fullfield(ip2);  % store thefull g values at the intersection in a structure data
 lines.ln(q).meterabs=mabsg(ip2);  % meter absolute gravity
 lines.ln(q).mg=mg(ip2);            % only meter grav no corrections
 lines.ln(q).ve=ve(ip2);
 lines.ln(q).lc=lc(ip2);
 lines.ln(q).xc=xc(ip2);
 lines.ln(q).vcc=vcc(ip2);
 lines.ln(q).al=al(ip2);
 lines.ln(q).ax=ax(ip2);
% lines.ln(q).drift=drift(ip2);
 lines.ln(q).eotvos=eotvos(ip2);
 lines.ln(q).gacc=gacc(ip2);
 lines.ln(q).latcorr=latcorr(ip2);
 lines.ln(q).egm=egm(ip2);
 lines.ln(q).level=level(ip2);
 lines.ln(q).lattitude=lt2(ip2);
 lines.ln(q).longitude=lo2(ip2);
 lines.ln(q).gpscorrections=GPStotal(ip2);
 
 
end

% plot meanline and all the lines
meanline=zeros(length(ip2),1);
meanfullg=zeros(length(ip2),1);
for c=1:n
 plot(lines.ln(c).g,mycolor{:,c}),title('Line repeats');
 hold on
 meanline=meanline+lines.ln(c).g; % calculate the mean line gravity
 meanfullg=meanfullg+lines.ln(c).fullg;
 end
meanline=meanline/n;
meanfullg=meanfullg/n;

plot(meanline);
hold off


figure
for c=1:n
 plot(lines.ln(c).longitude,lines.ln(c).g,mycolor{:,c}),title('Line repeats versus longitude');
 hold on

 end


for c=1:n
  cg=[cg;(lines.ln(c).g-meanline)];  % gravity error
  cfg=[cfg;(lines.ln(c).fullg-meanfullg)];
end 
  
% trim end from filter efects


MeanError=mean(abs(cg));
fprintf('\n');
fprintf('Mean Error %f \n',MeanError);
fprintf('\n');

........

% calculate the sigmas 
totalerror=[];
for c=1:n
sigma(c)=std(lines.ln(c).g-meanline);  
totalerror=[totalerror sigma(c)];
end   

for c=1:n
fprintf('Std line %d = %f \n',c,sigma(c));
end    
 
fprintf('\n');
fprintf('Mean Std %f \n',mean(totalerror));

% calculate mean error
 % Gravity{:,line}= lmeterPgrav{:,line}+lfGPS_Corrections{:,line}; % recompute full field gravity
 % GravityFreeAir{:,line}=lmeterPgrav{:,line}+lfGPS_Corrections{:,line}+lfLatcorr{:,line}; %  calculate free air
%  plot(lines.ln(1).meterabs+ lines.ln(1).gpscorrections+lines.ln(1).latcorr)


