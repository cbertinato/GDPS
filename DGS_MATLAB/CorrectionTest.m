% MiniTest

gps_lat=45;
gps_orthoheight=1000;
g1=-WGS84(gps_lat)-FAC2ord(deg2rad(gps_lat),gps_orthoheight);
g2=calc_facorrection(gps_lat,gps_orthoheight); % 
g2-g1