function GPSacc = GPS2MeterAxis(caccel,laccel,zaccel,MeterAxisVect)
% Projects vector (cross,long,up) to platform vertical
%
% GPSacc =GPS2MeterAxis(caccel,laccel,zaccel,MeterAxisVect)
% caccel: GPS cross acceleration (mGals)
% laccel: GPS long acceleration (mGals)
% zaccel: GPS total z acceleration (mGals)
% MeterAxisVect:matrix of platform up-vectors in (cross,long,up)
%
% GPSacc: GPS accelerations projected into Meter vertical axis

N = length(caccel);

GPSacc=zeros(N,1);

for i=1:N
    GPSacc(i)=dot(MeterAxisVect(:,i),[caccel(i) laccel(i) zaccel(i)]');
end

end

