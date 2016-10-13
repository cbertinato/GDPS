function [clat,clong,corthoheight,celipsoidheight] = LeverArmComp(lat,long,orthoheight,elipsoidheight,Pitch,Roll,Heading,X,Y,Z)
% LeverArmComp Computes delta Lattitude , longitude ,Height from Lever arm
% inputs:
% lat=godetic altiture
% 
% Pitch . Nose up positive in degreess
% Roll, Wing U/Dowm. Direction of the right hand in degrees 
% Heading, Rotation follow Right hand direction in degrees
% the lever Arma ofsets are defined in degrees
%
% from gravity meter to Antena in meters
% X cross direction Arm offset 
% Y forward lever Arm offse
% Z UP direction lever ARM

% Built vector from antena to gravity meter

V=[-X;-Y;-Z];

cp =cosd(Pitch); 
sp =sind(Pitch);
cr =cosd(Roll);
sr =sind(Roll);
ch =cosd(Heading);
sh =sind(Heading);

for n=1 : length(cp)
 Rp=[1 0 0;0 cp(n) -sp(n);0 sp(n) cp(n)]; % Pitch rotation around x axis
 Rr=[cr(n) 0 sr(n);0 1 0;-sr(n) 0 cr(n)]; % Roll rotation around y axis
 Rh=[ch(n) -sh(n) 0;sh(n) ch(n) 0;0 0 1]; % heading rotation around z axis
 RT=Rp*Rr*Rh;
 dpos=RT*V;
 delip(n)=dpos(3);
 dlat(n)=dpos(2);
 dlon(n)=dpos(1);
end

clat=lat;
clong=long;
corthoheight=delip'+orthoheight;
celipsoidheight=delip'+elipsoidheight;

end

