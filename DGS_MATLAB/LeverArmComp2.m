function [clat,clong,corthoheight,celipsoidheight] = LeverArmComp2(lat,long,orthoheight,elipsoidheight,Pitch,Roll,Heading,X,Y,Z)
% LeverArmComp Computes compensated Lattitude ,longitude ,Height from Lever
% arm and attitude angles
% 
% 
% inputs:
% lat=godetic lattitude, longitude Ortho hihgt and Elipsoidal high 
% Pitch . Nose up positive in degreess
% Roll, Wing U/Dowm. Direction of the right hand in degrees 
% Heading, Rotation follow Right hand direction in degrees
% the lever Arma ofsets are defined in degrees
%
% from gravity meter to Antena in meters
% X cross direction Arm offset (dx)
% Y forward lever Arm offse  (dl)
% Z UP direction lever ARM  (dh)

% Built variables from antena to gravity meter

ed=1.11585e5;
nd=1.11369e5;

X=-X;
Y=-Y;
Z=-Z;

cp =cosd(Pitch); 
sp =sind(Pitch);
cr =cosd(Roll);
sr =sind(Roll);
ch =cosd(Heading);
sh =sind(Heading);


dlong=(Y*sind(Pitch)+X*cosd(Pitch))./(ed*cosd(lat));
dlat=(Y*cosd(Pitch)-X*sind(Pitch))/nd;
dh=Z+Y*sind(Pitch)+X*sind(Roll);


clat=lat+dlat;
clong=long+dlong;
corthoheight=dh+orthoheight;
celipsoidheight=dh+elipsoidheight;

end

