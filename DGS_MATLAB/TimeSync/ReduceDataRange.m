function [xred,mx,sdx,linfit] = ReduceDataRange(x)
% reduce range of data by standardization, followed by detrending
%
% [xred,mx,sdx,linfit] = ReduceDataRange(x)
%
% x: input data
%
% xred: range-reduced data
% mx: mean of input data
% sdx: standard deviation of input data
% linfit: linear fit parameters

% get mean of input data
mx = mean(x);
sdx = std(x);

% check for non-zero data range
% 0 data range means constant

if max(x) - min(x) ~= 0
    % standardize data
    xred = (x - mx) / sdx;

    % generate a trend using valid data
    invec = 1:length(x);

    linfit = polyfit(invec',xred,1);

    % remove trend
    xred = xred - (polyval(linfit,invec))';

else
    xred = x - mx;
    linfit = [];
end
