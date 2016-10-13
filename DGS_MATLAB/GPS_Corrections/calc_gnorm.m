function gnorm=calc_gnorm(lat)
%Data Inputs
%1.Geodetic latitude: lat
latr=deg2rad(lat);
sin_lat = sin(latr);
sin_2lat=sin(2.*latr);
gnorm = 978031.85 * (1 + 0.005278895 * sin_lat.^2 + 0.000023462 * sin_lat.^4);

end

