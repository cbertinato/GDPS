function t = GPStimetoMLT(week,second)
% get MATLAB time from GPS time
%
% t = GPStimetoMLT(week,second)
%
% week: GPS week
% second: GPS second
%
% t: MATLAB datenum time

% 723186 is Jan 6, 1980 00:00:00 (start of GPS time)
% expressed in MATLAB time

t = 723186 + (week * 7) + (second / 86400);

end
