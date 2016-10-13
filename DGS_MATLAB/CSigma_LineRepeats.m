
% Calculates the sigma of a group of lines
% and prepares 

% load thelines
n=noflines;

% CheckTimming_ver2;
% CheckTimming_ver3;

% LineSeparation=0.005; % for Van test
LineSeparation=0.05; % for Biggedistance from East West bound tracks
RepeatFreq=3;      % 1 for airplane For  6 for van
% find the shorter line line 
maxlong=2000;
minlong=-2000;
for l=1:n                       % find maximun and minimyn longitude.
lo1=cell2mat(lgpslong(:,l));    % if test line is shorter than all other lines
M=max(lo1);                     % the intersection with each lina will have the same length
m=min(lo1);
if(M<maxlong)
    maxlong=M;
end
if(m>minlong)
    minlong=m;
end    
end

log=cell2mat(lgpslong(:,1));   % load the first line
ltg=cell2mat(lgpslat(:,1));
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
mycolor2={'green','blue','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow'};
% mycolor={'-k.','-g.','-b.','-c.','-r.','-m.','-y.','-k.','-g.','-b.','-c.','-r.','-m.','-y.'};
 mycolor={'k','g','b','c','r','m','y','k','g','b','c','r','m','k'};
% PlotPosition
% axis equal on

% plot lines and test line
figure;
hold on;
 for l=1:n
plot(111197*lgpslong{:,l}.*cos(pi* lgpslat{:,l}/180),111197* lgpslat{:,l},mycolor2{:,l}),title('Line repeats');
 end
 plot(111197*log.*cos(pi* ltg/180),111197* ltg);
 pause;
 hold off;
 close;


ln=[1 2 3 4 5 6 7 8 10 11 12 13];

cg=0;
cve=0;
cvcc=0;
cax=0;
cal=0;
cvcc=0;


for q=1:n    

mg=cell2mat(lmeterPgrav(:,q)); % only meter grav , GPS corrections
ve=cell2mat(lve(:,q));
vcc=cell2mat(lvcc(:,q));
al=cell2mat(lal(:,q));
ax=cell2mat(lax(:,q));

% drift=cell2mat(ldrift(:,q));

lo2=cell2mat(lgpslong(:,q));    % longitude of current line
lt2=cell2mat(lgpslat(:,q));     % lattitude of current line
% Tilt=cell2mat(lLongTilt(:,q));

gacc=cell2mat(lgpsacc(:,q));
level=cell2mat(lLevelError(:,q));
latcorr=cell2mat(lfLatcorr(:,q));
eotvos=cell2mat(lfEotvos(:,q));
% freeair=cell2mat(lFreeair(:,q));
% GPStotal=cell2mat(lGPStotalacc_OnSensor(:,q));
 GPStotal=cell2mat(lfGPS_Corrections(:,q));
 % totg=mg+GPStotal-level; %+gravitymeteroffset no level correctio;
  totg=mg+GPStotal; % with level correction
[line1samp, line2samp] = FindLineIntersections(log,ltg,lo2,lt2); % log and ltg are the generated 
 ip2=round(line2samp);
 
 lines.ln(q).x=ip2;         % store the index of the intersection in a structure
 lines.ln(q).g=totg(ip2);      % store the g values at the intersection in a structure data
 lines.ln(q).mg=mg(ip2);   % only meter grav no corrections
 lines.ln(q).ve=ve(ip2);
 lines.ln(q).vcc=vcc(ip2);
 lines.ln(q).al=al(ip2);
 lines.ln(q).ax=ax(ip2);
 lines.ln(q).l2=l2(ip2);
 lines.ln(q).x2=x2(ip2);

% lines.ln(q).drift=drift(ip2);
 
 lines.ln(q).eotvos=eotvos(ip2);
 lines.ln(q).gacc=gacc(ip2);
 lines.ln(q).latcorr=latcorr(ip2);
% lines.ln(q).freeair=freeair(ip2);
 lines.ln(q).level=level(ip2);

% store the the lines and monitor to do cross coupling analisys 
 % cbv=[cbv;bv(ip2)];
 % cve=[cve;ve(ip2)];
 % cax=[cax;ax(ip2)];
 % cal=[cal;al(ip2)];
 % cvcc=[cvcc;vcc(ip2)];
 % cax2=[cax2;ax2(ip2)];
 % cal2=[cal2;al2(ip2)];
 % ca2l2=[ca2l2;a2l2(ip2)];
 % ca2x2=[ca2x2;a2x2(ip2)];
 % cvz=[cvz;vz(ip2)];
end


% plot meanline and all the lines
meanline=zeros(length(ip2),1);
for c=1:n
 plot(lines.ln(c).g,mycolor{:,c}),title('Line repeats');
 hold on
 meanline=meanline+lines.ln(c).g; % calculate the mean line gravity
 end
meanline=meanline/n;
plot(meanline,'-k.');
hold off

% g=egm08_interp(lt2,lo2,h);
% meangeoid=mean(g(1:end-1000));

for c=1:n
  cg=[cg;(lines.ln(c).g-meanline)]; 
end   

MeanError=mean(abs(cg));
fprintf('Calculated Meand and Line Repeats\n');
fprintf('\n');
fprintf('Mean Error %f \n',MeanError);
fprintf('\n');


% calculate the sigmas 
totalerror=[];
error=[];
for c=1:n
sigma(c)=std(lines.ln(c).g-meanline);  
totalerror=[totalerror sigma(c)];
end   

for c=1:n
fprintf('Std line %d = %f \n',c,sigma(c));
end    
 
fprintf('\n');
fprintf('Mean Std %f \n',mean(totalerror));

fprintf(' ________________________________\n');

% calculate mean error



