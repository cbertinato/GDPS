function extrap = PFExtrap(data,padl,padr,pflen)
% extrapolates data using predictive filtering
%
% PFExtrap(data,padl,padr,pflen)
%
% data: data sequence to be extrapolated
% padl: padding on left side
% padr: padding on right side
% pflen: prediction filter length to use (OPTIONAL)
%        default is 30
%
% extrap: extrapolated sequence

% get sizes
norig = length(data);
next = norig + padl + padr;

if nargin < 4
    pflen = 30;
end

% initialize extrapolated data
extrap = [zeros(padl,1); data; zeros(padr,1)];

% find prediction filter
pf=lpc(data,pflen)';
pf=-pf(2:end);

% extrapolate left
power0 = sum(extrap(padl+1:padl+pflen).^2);
pmin = 1e-6*power0;
count = 0;
for k=padl:-1:1
    extrap(k) = sum(pf.*extrap(k+1:k+pflen));
    count = count + 1;
    if mod(count,pflen) == 0
        power=sum(extrap(k+1:k+pflen).^2);
        if power < pmin
            break;
        end
    end
end

% extrapolate right
pf=flipud(pf);
power0 = sum(extrap(padl+norig+1-pflen:padl+norig).^2);
pmin = 1e-6*power0;
count = 0;
for k = padl+norig+1:next
    extrap(k) = sum(pf.*extrap(k-pflen:k-1));
    count = count + 1;
    if mod(count,pflen) == 0
        power=sum(extrap(k-pflen:k-1).^2);
        if power < pmin
            break;
        end
    end    
end
