% PlotStatus.m
% Plot all the Status bolean variables
st=dat.status;

 clamp=bitget(st,1);
 unclamp=bitget(st,2);
 GPSsync=bitget(st,3);
 feedback=bitget(st,4);
 R1=bitget(st,5);
 R2=bitget(st,6);
 ADlock=bitget(st,7);
 Rcvd=bitget(st,8);
 NavMod1=bitget(st,9);
 NavMod2=bitget(st,10);
 PlatCom=bitget(st,11);
 SensCom=bitget(st,12);
 GPStime=bitget(st,13);
 ADsat=bitget(st,14);


 clamp(~clamp)=nan; %set zero values to nan
 unclamp(~unclamp)=nan;
 GPSsync(~GPSsync)=nan;
 feedback(~feedback)=nan;
 R1(~R1)=nan;
 R2(~R2)=nan;
 ADlock(~ADlock)=nan;
 Rcvd(~Rcvd)=nan;
 NavMod1(~NavMod1)=nan;
 NavMod2(~NavMod2)=nan;
 PlatCom(~PlatCom)=nan;
 SensCom(~SensCom)=nan;
 GPStime(~GPStime)=nan;
 ADsat(~ADsat)=nan;
 
 
 

%% make plots
h=figure;
% status bars
%ax1=subplot(5,1,1:2); %use the top 3 slots for status bars
plot(clamp,'LineWidth',6,'Color',rgb('Green'));hold on
plot(unclamp.*2,'LineWidth',6,'Color',rgb('Red'));
plot(GPSsync.*3,'LineWidth',6,'Color',rgb('DarkBlue'));
plot(feedback.*4,'LineWidth',6,'Color',rgb('Black'));
plot(R1.*5,'LineWidth',6,'Color',rgb('Violet'));
plot(R2.*6,'LineWidth',6,'Color',rgb('DarkViolet'));
plot(ADlock.*7,'LineWidth',6,'Color',rgb('Silver'));
plot(Rcvd.*8,'LineWidth',6','Color',rgb('Gray'));
plot(NavMod1.*9,'LineWidth',6,'Color',rgb('SandyBrown'));
plot(NavMod2.*10,'LineWidth',6,'Color',rgb('Brown'));
plot(PlatCom.*11,'LineWidth',6,'Color',rgb('Green'));
plot(SensCom.*12,'LineWidth',6,'Color',rgb('Red'));
plot(GPStime.*13,'LineWidth',6,'Color',rgb('DarkBlue'));
plot(ADsat.*14,'LineWidth',6,'Color',rgb('Black'));

ylim([0.5 14.5]);
datetick('x');
set(gca,'YTickMode','manual','YTick',[1:14],'YTickLabel',{'Clamp','Unclamp','GPSsync','Feedback','R1','R2','ADlock','Rcvd','NavMod1','NavMod2','PlatCom','SensCom','GPSin','ADsat'});
title('Status Bits');
hold off;
