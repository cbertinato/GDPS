function n = Next2357(nin)

if mod(nin,2) ~= 0
    nin = nin + 1;
end

while max(factor(nin)) > 7
    nin = nin + 2;
end

n = nin;

end
