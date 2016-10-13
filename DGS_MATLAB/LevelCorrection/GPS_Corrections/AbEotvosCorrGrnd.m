function EC = AbEotvosCorrGrnd(ve, vn, ht, phi)
% calculates airborne Eotvos correction
% correction uses speed over ground
%
% EC = AbEotvosCorrAlt(ve, vn, ht, phi)
%
% ve: east velocity (m/s)
% vn: north velocity (m/s)
% ht: height (meters)
% phi: latitude (degrees)
%
% EC: Eotvos correction (milliGals)

% WGS84 ellipsoid params
a = 6378137;
eps = 1/298.2572236;
omega = 7292115e-11;

sinphi = sind(phi);

s2phi = sinphi .^ 2;
hovera = ht / a;

EC = ((vn .^ 2) .* (1 + hovera + eps * (2 - 3 * s2phi)) / a ...
    + (ve .^ 2) .* (1 + hovera - eps * s2phi) / a ...
    + 2 * omega * ((ve .* cosd(phi)).*(1+hovera))) * 1e5;

end
