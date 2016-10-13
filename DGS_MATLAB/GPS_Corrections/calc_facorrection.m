function fad=calc_facorrection(lat,ht)
%fad is the free-air disturbance
%Data Inputs
%1.Geodetic latitude: lat
%2.ELLIPSOIDAL height: ht
%3.Full-Field Gravity at Altitude: ffg
fac=calc_fac(lat,ht); %free air correction
gnorm=calc_gnorm(lat); %normal gravity
fad=fac-gnorm;
end

