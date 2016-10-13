function g = GRS80(lat)

sinlam = sind(lat);

sinsqlam = sinlam .^ 2;

num = 1 + 0.001931851353 * sinsqlam;

den = sqrt(1 - 0.00669438002290 * sinsqlam);

g = 978032.67715 * (num ./ den);

end
