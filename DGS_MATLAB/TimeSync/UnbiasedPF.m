function ubpf = UnbiasedPF(x,pflen)
% calculates unbiased prediction filter from data
%
% x: data
% pflen: filter length
%
% ubpf: unbiased prediction filter

% find autocorrelation of input data

% look for longest run of valid data
valid = ~isnan(x);
dvalid = diff(valid);
run_start = find(dvalid > 0) + 1;
if valid(1)
    run_start = [1 ; run_start];
end

run_end = find(dvalid < 0);
if valid(end)
    run_end = [run_end ; length(x)];
end

run_length = (run_end - run_start) + 1;

[maxrun, maxind] = max(run_length);

if maxrun > 50*pflen
    i1 = run_start(maxind);
    i2 = run_end(maxind);
    ac = xcorr(x(i1:i2),pflen,'coeff');
    ac=ac(pflen+1:end);
else
    ac = AutoCorrNaNs(x,pflen);
end

% generate Toeplitz system
T = toeplitz(ac(1:end-1)');

rhs = ac(2:end);

% solve system with unbiased constraint
cplus = ones(pflen,1)/pflen;
Z=eye(pflen)-(ones(pflen,pflen)/pflen);

[U S V] = svd(T*Z);

splus = ones(pflen,1) ./ diag(S,0);
condnum = splus / splus(1);
splus(condnum > 1e6) = 0;

TZinv = V * diag(splus,0) * U';

ubpf=cplus+TZinv*(rhs-T*cplus);