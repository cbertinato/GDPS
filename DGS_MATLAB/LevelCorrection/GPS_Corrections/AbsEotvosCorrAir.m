function [ Eotvos ] = AbsEotvosCorrAir(gps_lat,gps_height,gps_Evel, gps_Nvel )
% Air Eotvos correction
%  gps_Lat=lattitude in degress

 a=6378137;             %semi-major axis, WGS-84 i
 f=0.00335281066474;    %flattening, WGS84
 omega=7.292115e-5;     % earth rotation rate 7 292 115.0 x1011
 
  Eotvos=2*omega*gps_Evel.*cos(gps_lat*pi/180)+...
  gps_Nvel.^2/a.*(1+gps_height/a+f*(2-3*(sin(gps_lat*pi/180)).^2))+...
  gps_Evel.^2/a.*(1+gps_height/a+f*(sin(gps_lat*pi/180)).^2);
  Eotvos=100000*Eotvos;


end

