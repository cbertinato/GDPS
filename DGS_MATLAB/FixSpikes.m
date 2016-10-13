% FixSpikes.m 
% matlab script to correct data spikes from data
 
fixed=dat.grv;

 Taps=2*20; % 
 Bspike = fir1(Taps,1/Taps,blackman(Taps+1));
 gravin=filtfilt(Bspike,1,fixed);
 fg=filtfilt(Bspike,1,fixed);
 n=length(fg);
 
 c=1;
while 1
  fg=filtfilt(Bspike,1,fixed);
 n=length(fg);   
 figure(1)
 plot(fg(c:c+2000));
 pause
 [pos,g] = ginput(2); 
  x=round(pos(1));
  y=round(pos(2));
  mystd=std(fixed(c+x:c+y)); % calculate std for the block
  fixed(c+x:c+y)=NaN;       % fill the spike with NaN
  fixed=FillDataGaps(fixed); % intrpolate the Spike
  
  nl=length( fixed(c+x:c+y)); % calculate number of NaN
  noise=mystd/100*(rand(nl,1)-0.5); % 
  fixed(c+x:c+y)=fixed(c+x:c+y)+noise;
  
  
  c=c+y


if (c>=n)
break;
end  

 CC = inputdlg('More Spikes?','Format',1,{'N'});
 CC = char(CC);
    if CC=='Y' 
   break;
    end
end

figure(2)
plot(gravin);
hold on
ffixed=filtfilt(Bspike,1,fixed);
plot(ffixed,'green');
hold off

figure(3)
fa=filtfilt(B,1,dat.grv);
fb=filtfilt(B,1,fixed);
plot(fa);
hold on
plot(fb,'green');
hold off
  

