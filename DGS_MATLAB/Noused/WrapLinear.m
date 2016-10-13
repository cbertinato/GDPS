function wrap = WrapLinear(norig,padl,padr,linfit)

nex = norig + padl + padr;

sys = zeros(6,6);
rhs = zeros(6,1);

alin = linfit(1);
blin = linfit(2);

powers=5:-1:0;

xp = ones(1,6);

sys(1,:) = xp;
rhs(1) = (alin * norig) + blin;

sys(2,1:5) = sys(1,2:6).*powers(1:5);
rhs(2) = alin*(norig-1);

sys(3,1:4) = sys(2,2:5).*powers(1:4);

xvec = (nex / (norig-1))*ones(1,6);
xp = xvec.^powers;

sys(4,:) = xp;
rhs(4) = alin + blin;

sys(5,1:5) = sys(4,2:6).*powers(1:5);
rhs(5) = alin*(norig-1);

sys(6,1:4) = sys(5,2:5).*powers(1:4);

wpoly=sys\rhs;

wrap = zeros(nex,1);

xeval = nex-padl+1:nex;
xeval = (xeval-1)/(norig-1);
wrap(1:padl) = polyval(wpoly,xeval);

xeval=1:norig;
wrap(padl+1:padl+norig) = polyval(linfit,xeval);

xeval = norig+1:nex-padl;
xeval = (xeval-1)/(norig-1);
wrap(padl+norig+1:nex) = polyval(wpoly,xeval);



