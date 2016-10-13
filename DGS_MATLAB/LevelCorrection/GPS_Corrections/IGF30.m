function g = IGF30(lat)

sinlat = sind(lat);

sin2lat = sind(2*lat);

g = 978049 * (1+(0.0052884 * (sinlat .^ 2)...
    - 0.0000059 * (sin2lat .^ 2)));

end
