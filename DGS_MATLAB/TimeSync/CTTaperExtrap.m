function tapered = CTTaperExtrap(data,norig,padl,padr)

match = 0.5*(data(1)+data(end));

delta = match - data(1);
args = linspace(0,pi,padl);
wt = 0.5 * (cos(args) + 1.0);
data(1:padl) = data(1:padl) + (wt' * delta);

delta = match - data(end);
args = linspace(0,pi,padr);
wt = 0.5 * (1.0 - cos(args));
data(norig+padl+1:end) = data(norig+padl+1:end) + (wt' * delta);

tapered = data;