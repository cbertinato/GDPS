function [Longa,Crossa] = Platform_controller_simulation(gpsacclong,gpsacccross,gz,sampling)
% Platform controller simulation
% inputs  gpsacclong  gpsacccross mGals
%         gz=platform total vertical acceleration
%         sampling sampling frequency 
% outputs crossa , longa angles in radians
% This funtion used the the hadcoded  parameters
% d=damping as recorded in the meter ini file
% p=period parameter as a recorded in the ini file

if(nargin == 2)
    gz=1e6;
end

if(nargin == 3)
    sampling=1;
end
% load the platform parameters from the ini file
d=550;
p=0.1;
% end platform parameter

g=gz/1e6;
deg2rad=pi/180;

gpsacclong(find(isnan(gpsacclong)))=0;
gpsacccross(find(isnan(gpsacccross)))=0;
gz(find(isnan(gz)))=0;

%pre filter for smoth the gps inputs
filtertime=20; % set here the desired filter 
Tapp=sampling*filtertime; % Taps for platform simulation tilt
Bplat=fir1(Tapp,1/Tapp,blackman(Tapp+1));
fgpsacclong=filter(Bplat,1,gpsacclong);
fgpsacccross=filter(Bplat,1,gpsacccross);
gpsacclong=fgpsacclong(Tapp/2:end);
gpsacccross=fgpsacccross(Tapp/2:end);
pad=zeros(Tapp/2-1,1);
gpsacclong=[gpsacclong; pad];
gpsacccross=[gpsacccross; pad];
% end pre filter


n=length(gpsacclong);
% Tilta=zeros(1,n);

% start platform simulation for long axis
ingpsacc=1e-6*gpsacclong;
SumAcc=0;
GyroSum=0;
Tilta=[];
Accelerometer=ingpsacc(1);
for i=1:n-1
% accelerometer loop simulation
SumAcc=SumAcc+Accelerometer/sampling;	% controller integrator	
OutAcc=d * Accelerometer +100*SumAcc * p;
% simulate the gyro presession loop
GyroSum=GyroSum+0.003145725* OutAcc/sampling;
 Accelerometer=ingpsacc(i+1)*cos(pi/180*GyroSum)-g(i+1)*sin(pi/180*GyroSum); % asume g is constant
 Tilta=[Tilta GyroSum]; % tilt in degrees
end
Longa=Tilta*deg2rad; % copy the tilt and conver to radians
Longa=[0 Longa];
Longa=-Longa';

% start platform simulation cross axis
ingpsacc=1e-6*gpsacccross;
SumAcc=0;
GyroSum=0;
Tilta=[];
Accelerometer=ingpsacc(1);
for i=1:n-1
% accelerometer loop simulation
SumAcc=SumAcc+Accelerometer/sampling;	% controller integrator	
OutAcc=d * Accelerometer +100*SumAcc * p;
% simulate the gyro presession loop
GyroSum=GyroSum+0.003145725* OutAcc/sampling;
 Accelerometer=ingpsacc(i+1)*cos(pi/180*GyroSum)-g(i+1)*sin(pi/180*GyroSum); % asume g is constant
 Tilta=[Tilta GyroSum]; % tilt in degrees
end
Crossa=deg2rad*Tilta; % copy the tilt and conver to radians since the platform model is built
                    % to output the resulting tilt in degreess Crossa=[0 Crossa];Crossa=Crossa';
Crossa=[0 Crossa];
Crossa=-Crossa';
% save Daniangles Crossa Longa;
end



