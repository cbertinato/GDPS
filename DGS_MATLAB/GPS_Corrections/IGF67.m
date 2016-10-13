function g = IGF67(lat)

sinlat = sind(lat);

sin2lat = sind(2*lat);

g = 978031.846 * (1+(0.0053024 * (sinlat .^ 2)...
    - 0.0000058 * (sin2lat .^ 2)));

end
