function [num,den]=TiltFilter(T0,dt,f)

% TiltFilter - returns filter coefficients for L&R platform tilt
% computation
%
% [num den]=TiltFilter(T0,dt,f)
% num, den: filter coefficients numerator and denominator
% T0: platform period, seconds
% dt: sample increment, seconds
% f: platform damping (optional, default sqtr(2)/2)

if(nargin == 2)
    f = sqrt(2.0)/2;
end

%frequencies
omega0 = (2 * pi) / T0;
omegas = 1/sqrt(6371100/9.8);

OM0 = (2 / dt) * tan(omega0 * dt / 2);
OMS = (2 / dt) * tan(omegas * dt / 2);

% first stage substitutions
a = (OMS * OMS) - (OM0 * OM0);
b = 2 * f * OM0 * (2 / dt);
c = 4 / (dt * dt);
d = OM0 * OM0;

% second stage substitutions
d0 = b + c + d;
b0 = (a - b) / d0;
b1 = 2 * a / d0;
b2 = (a + b) / d0;
a1 = 2 * (d - c) / d0;
a2 = (c + d - b) / d0;

num = [b0 b1 b2];
den = [1 a1 a2];

end


