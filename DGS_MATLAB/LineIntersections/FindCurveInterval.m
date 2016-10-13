function index = FindCurveInterval(x,y,xpt,ypt)
% FindCurveInterval: finds interval on curve(x,y) which contains (xpt,ypt)
%
% index = FindCurveInterval(x,y,xpt,ypt)
% x: curve x-coordinates
% y: curve y-coordinates
% xpt: test point x-coordinate
% ypt: test point y-coordinate
%
% index: fractional index on curve (via linear interpolation)
% which contains test point
%

% find sign changes with respect to x,y
chx = diff((x-xpt)<=0);
chy = diff((y-ypt)<=0);

% look for simultaneous sign changes in x and y
interval = find((chx ~= 0) & (chy ~= 0));

% find fractional index via least squares
A = [x(interval+1)-x(interval) ; y(interval+1)-y(interval)];
b = [xpt-x(interval); ypt-y(interval)];
index = interval + (dot(A,b)/dot(A,A));
