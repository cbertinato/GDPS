function [t,dly]=calc_grv_delay(tgrv,grv,tvacc,vacc,wl,tag)
%This function calculates the delay of the gravimeter signal compared to
%the gps signal based on a comparison of raw meter gravity and vertical
%acceloration
%
%USAGE:
%   [t,dly]=calc_grv_delay(tgrv,grv,tvacc,vacc);
%   [t,dly]=calc_grv_delay(tgrv,grv,tvacc,vacc,wl);
%   [t,dly]=calc_grv_delay(tgrv,grv,tvacc,vacc,wl,tag);
%
%INPUT
%   tgrv     Array of time in seconds either from the start of the day or from the start
%          of the track of the raw meter gravity
%   grv      Array of raw meter gravity in mgals
%   tvacc     Array of time in seconds either from the start of the day or
%          from the start of the track of the vertical accelorations
%   vacc      Array vertical acceloration in mgal
%   wl        window length in minutes
%   tag   STRING identifier added to plot titles
%
%OUTPUT
%   t   Array of the center times for the significant windows
%   dly   Array of the best delays in meter grv for all significant windows with post shift correlation
%           coefficients > bc_min (default 0.95)
%   plot showing the shifted gravity with vacc in the top subplot and the
%           best delay for windows with cc>threshhold in bottom subplot
%
%DESCRIPTION
%   This function works by breaking data into windows (4 min default length) with each 
%   window overlapping half of the previos window. For each 4 minute 
%   window the best delay in grv is found. The window is deemed to have a 
%   significant correlation if the post delay correlation coefficient is
%   >0.95. If fewer than 5 windows have a correlation coefficient >0.95 the threshhold
%   is dropped to 0.85
%
%Created by Sandra Preaux, NGS October 2009
%Modified to reduce correlation threshold if needed, Sandra Preaux April 2011
%Cleaned up & comments edited for v1.2, S. Preaux June 2011
%Modified for DGS's Eotvos alpha Oct 2015 S.Preaux: use raw_grv vs vacc,
%   allow flexible window sizing

if nargin<5
    wl=4; %default window length of 4 minutes
end
if nargin<6 %no identifier provided set to empty string
    tag='';
end

% make sure both signals start at the same time within 0.01 sec
tgrv=floor(tgrv.*100)./100;
tvacc=floor(tvacc.*100)./100;
if tgrv(1)~=tvacc(1)
    error('GRAVD:calc_grv_delay:TimeError','Starting times do not match');
end

%interpolate both signals to get 0.01 sec resolution
ti=tgrv(1):0.01:tgrv(end);
grvi=interp1(tgrv,grv,ti);
vacci=interp1(tvacc,vacc,ti);

%window loop
md=120*100; %set max delay to 30 seconds this allows for inclusion of GPS/UTC offset in time delay
wsize=(wl*60*100)+1; %set window size to 4 minutes + 0.01 sec
wi=(wsize-1)/2; %set interval to move to next window
ws=1;
we=wsize;
t=[];
dly=[];
bc_min=0.95;
temp=zeros(1,1);
while we<=length(ti)
    c=xcov(vacci(ws:we),grvi(ws:we),md,'coeff');
    [bc,di]=max(c);
    temp(end+1)=bc;
    if bc>=bc_min
        dtemp=(di-md-1)/100; %calculate the best delay in seconds
        t=[t,ti(ws+wi)];
        dly=[dly,dtemp];
    end
    %next window
    ws=ws+wi;
    we=we+wi;
end
if length(t)<5 %if fewer than 5 windows reach 95% correlation drop to 85% threshold
    ws=1;
    we=wsize;
    t=[];
    dly=[];
    bc_min=0.85;
    while we<=length(ti)
        c=xcov(vacci(ws:we),grvi(ws:we),md,'coeff');
        [bc,di]=max(c);
        if bc>=bc_min
            dtemp=(di-md-1)/100; %calculate the best delay in seconds
            t=[t,ti(ws+wi)];
            dly=[dly,dtemp];
        end
        %next window
        ws=ws+wi;
        we=we+wi;
    end
end

%make plots
figure;
subplot(2,1,1);
plot(tvacc,vacc,'g');
set(gca,'YTickLabel',num2cell(get(gca,'YTick')));
temp=get(gca,'XTick');
hr=floor(temp./3600);
temp=temp-hr.*3600;
mins=floor(temp./60);
temp=temp-mins.*60;
for i=1:length(hr)
    tt{i}=[num2str(hr(i)),':',num2str(mins(i)),':',num2str(temp(i))];
end
set(gca,'XTickLabel',tt);
hold on
plot((tgrv+median(dly)),grv);
title(sprintf('%s Vertical Acceleration and Raw Meter Gravity Shifted by %4.2f seconds',tag,median(dly)));
subplot(2,1,2);
plot(t,dly,'*');
temp=get(gca,'XTick');
hr=floor(temp./3600);
temp=temp-hr.*3600;
mins=floor(temp./60);
temp=temp-mins.*60;
for i=1:length(hr)
    tt{i}=[num2str(hr(i)),':',num2str(mins(i)),':',num2str(temp(i))];
end
set(gca,'XTickLabel',tt);
xlabel('Time (Hr:Min:Sec)');
title(['Best Delay for ',num2str(wl),' minute windows resulting in correlation coeff. > ',num2str(bc_min)]);