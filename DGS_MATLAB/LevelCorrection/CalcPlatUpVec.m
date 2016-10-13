function upvecs = CalcPlatUpVec(tiltc,tiltl)
% CalcPlatUpVec: calculate platform up-vector from tilts
%
% upvecs = CalcPlatUpVec(tiltc,tiltl)
% 
% upvecs: 3xN matrix of platform up-vectors in
%         (cross, long, up) coords
% tiltc: vector of cross-axis tilt angles (rads)
% tiltl: vector of long-axis tilt angles (rads)

% get tilt increments
% assume initial tilt is zero
 incTc = [tiltc(1) ; diff(tiltc)];
 incTl = [tiltl(1) ; diff(tiltl)];

% trig functions of tilts
% sc = sin(incTc);
% cc = cos(incTc);
% sl = sin(incTl)
% cl = cos(incTl);
sc = sin(tiltc);
cc = cos(tiltc);
sl = sin(tiltl);
cl = cos(tiltl);

% initialize upvectors
n = length(tiltc);
upvecs = zeros(3,n);

% start with vertical platform
platup = [0 0 1]';

for i=1:n
    
    % rotation matrices
    cci = cc(i);
    sci = sc(i);
    rotc = [cci 0 -sci ; 0 1 0 ; sci 0 cci];
    
    cli = cl(i);
    sli = sl(i);
    rotl = [1 0 0 ; 0 cli -sli ; 0 sli cli];
    
    % alternate which rotation is first
    platup = [0 0 1]';
    if mod(i,2) == 0
        platup = rotc * (rotl * platup);
    else
        platup = rotl * (rotc * platup);
    end
    
    upvecs(:,i) = platup;
    
end

end

    

