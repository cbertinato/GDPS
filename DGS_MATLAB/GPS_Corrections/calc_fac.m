function fac=calc_fac(ht,lat,ell)
% Function to calculate the free air correction 
%
%USAGE: 
%   fac=calc_fac(ht);
%   fac=calc_fac(ht,lat);
%   fac=calc_fac(ht,lat,ell);
%
%INPUT
%   ht      Array of ellipsoidal heights in meters
%   lat     OPTIONAL, array of latitude in decimal degrees, if included the
%               2nd order calculation is used
%   ell     OPTIONAL default is WGS84
%
%OUTPUT
%   fac     Array of free air corrections in mgals
%
%BACKGROUND and SOURCES
%Ellipsoid parameters
%for WGS84 (pgs 3-5 to 3-6):
%http://earth-info.ngs.mil/GandG/publications/tr8350.2/wgs84fin.pdf
%for GRS80:
%Hackney and Featherstone (2003) Geophys J. Int. c154, p.35-43.
%
% Modified by Sandy Preaux, Nov 2010 to allow ellipsoid selection

switch nargin
    case 1
        % free-air correction- linear approximation
        factor = 0.3086;
        reference_alt = 0.0; %0 unless processing on a different datum than height was recorded
        fac = (ht-reference_alt) .* factor;
    case 2
        ell='WGS84';
        fac=calc_fac(ht,lat,ell);
    case 3
        switch ell
            case 'GRS80'
                a = 6378137; %semi-major axis (same for GRS80 and WGS84)
                g_e = 978032.67715; %equatorial normal gravity GRS80
                f = 0.00335281068118; %flattening GRS80
                m = 0.00344978600308; %GRS80- defined as (w^2*a^2*b)/GM
            case 'WGS84'
                a = 6378137; %semi-major axis (same for GRS80 and WGS84)
                g_e = 978032.53359; %equatorial normal gravity WGS84
                f = 0.00335281066474; %flattening WGS84
                m = 0.00344978650684; %WGS84- defined as (w^2*a^2*b)/GM
            otherwise
                fac=[];
                error('Newton:calc_fac:inputerror',['eillipsoid ',ell,' not supported']);
        end
        %use GEOCENTRIC latitude. def: phi
        phi = atan(tand(lat).*((1-f).^2));
        sphi2 = sin(phi).^2;
        ht2 =ht.^2;
        
        c1 = ((2.*g_e)./a);
        term1 = (1+f+m-(2.*f.*sphi2)).*ht;
        c2 = (3.*g_e./(a.^2));
        term2 = ht2;
        
        fac = (c1.*term1)-(c2.*term2);
    otherwise
        fac=[];
        error('Newton:calc_fac:inputerror','Incorrect number of input arguments');
end