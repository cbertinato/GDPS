function nopt = NextSmallPrimeFact(nin)
% find next higher number which is optimal for FFT
% optimal is even and no prime factors > 5
%
% nopt = NextSmallPrimeFact(nin)
%
% inputs
% nin: staring point for search
%
% outputs
% nopt: optimal number

% make sure we start with an even number
if mod(nin,2) ~= 0
    nin = nin + 1;
end

% keep adding 2 until max prime factor is <= 5
while max(factor(nin)) > 5
    nin = nin + 2;
end

nopt = nin;

end
