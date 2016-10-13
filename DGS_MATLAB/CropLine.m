filtertime=100;
filterlength=filtertime;    % 
 Taps=2*filterlength*sampling; % 
 B= fir1(Taps,1/Taps,blackman(Taps+1)); % filter for 1 sec data

n = inputdlg('Line number','Line',1,{'0'});
linenumber= str2num(char(n));

y1s=cell2mat(GravityFreeAir(:,linenumber)); 
% y1s=y1s(Taps:end-Taps);

y=filtfilt(B,1,GravityFreeAir{:,linenumber});
y=y(Taps:end-Taps);

n=length(y);
x=[1:1:n];
figure
h=plot(x,y);
set(h,'XDataSource','x');
set(h,'YDataSource','y');
[xp,yp] = ginput(2);

x=round(xp(1));
y=round(xp(2));

GravityFreeAir{:,linenumber}=y1s(x:y);

y1s=cell2mat(Gravity(:,linenumber));
Gravity{:,linenumber}=y1s(x:y);
y1s=cell2mat(lmeterPgrav(:,linenumber));
lmeterPgrav{:,linenumber}=y1s(x:y);
y1s=cell2mat(lmeterg(:,linenumber));
lmeterg{:,linenumber}=y1s(x:y);
y1s=cell2mat(legm(:,linenumber));
legm{:,linenumber}=y1s(x:y);
y1s=cell2mat(llong(:,linenumber));
llong{:,linenumber}=y1s(x:y);
y1s=cell2mat(lcross(:,linenumber));
lcross{:,linenumber}=y1s(x:y);
y1s=cell2mat(lve(:,linenumber));
lve{:,linenumber}=y1s(x:y);
y1s=cell2mat(lvcc(:,linenumber));
lvcc{:,linenumber}=y1s(x:y);
y1s=cell2mat(lax(:,linenumber));
lax{:,linenumber}=y1s(x:y);
y1s=cell2mat(lal(:,linenumber));
lal{:,linenumber}=y1s(x:y);
y1s=cell2mat(llc(:,linenumber));
llc{:,linenumber}=y1s(x:y);
y1s=cell2mat(lxc(:,linenumber));
lxc{:,linenumber}=y1s(x:y);
y1s=cell2mat(lmeter(:,linenumber));
lmeter{:,linenumber}=y1s(x:y);
y1s=cell2mat(lfgpsacclong(:,linenumber));
lfgpsacclong{:,linenumber}=y1s(x:y);
y1s=cell2mat(lfgpsacccross(:,linenumber));
lfgpsacccross{:,linenumber}=y1s(x:y);
y1s=cell2mat(lpress(:,linenumber));
lpress{:,linenumber}=y1s(x:y);
y1s=cell2mat(ltemp(:,linenumber));
ltemp{:,linenumber}=y1s(x:y);
y1s=cell2mat(lgpslong(:,linenumber));
lgpslong{:,linenumber}=y1s(x:y);
y1s=cell2mat(lgpslat(:,linenumber));
lgpslat{:,linenumber}=y1s(x:y);
y1s=cell2mat(lgpsacc(:,linenumber));
lgpsacc{:,linenumber}=y1s(x:y);
y1s=cell2mat(lfLatcorr(:,linenumber));
lfLatcorr{:,linenumber}=y1s(x:y);
y1s=cell2mat(lLevelError(:,linenumber));
lLevelError{:,linenumber}=y1s(x:y);
% y1s=cell2mat(flight(:,linenumber));
% flight{:,linenumber}=y1s(x:y);
% y1s=cell2mat(Lname(:,linenumber));
% Lname{:,linenumber}=y1s(x:y);
y1s=cell2mat(lweek(:,linenumber));
lweek{:,linenumber}=y1s(x:y);
y1s=cell2mat(lweeksec(:,linenumber));
lweeksec{:,linenumber}=y1s(x:y);
y1s=cell2mat(lfEotvos(:,linenumber));
lfEotvos{:,linenumber}=y1s(x:y);
y1s=cell2mat(lgps_height(:,linenumber));
lgps_height{:,linenumber}=y1s(x:y);
y1s=cell2mat(lorto_height(:,linenumber));
lorto_height{:,linenumber}=y1s(x:y);
y1s=cell2mat(lftiming_Meter(:,linenumber));
lftiming_Meter{:,linenumber}=y1s(x:y);
y1s=cell2mat(lfTimingGPS(:,linenumber));
lfTimingGPS{:,linenumber}=y1s(x:y);
y1s=cell2mat(lfGPS_Corrections(:,linenumber));
lfGPS_Corrections{:,linenumber}=y1s(x:y);


CC = inputdlg('Save Flight/Survay  Changes?','Save',1,{'N'});
Save= char(CC);

if Save=='Y' % save corrected lines
    
save thelines Gravity  GravityFreeAir lmeterPgrav  lmeterg legm  llong lcross lve lvcc lax lal llc lxc lmeter lfgpsacclong lfgpsacccross...
     lpress ltemp  lgpslong lgpslat lgpsacc lfLatcorr lLevelError flight Lname lweek lweeksec...
     noflines lfEotvos lgps_height  lorto_height lftiming_Meter lfTimingGPS TideGravity PreTieReading lfGPS_Corrections sampling Taps;
end




