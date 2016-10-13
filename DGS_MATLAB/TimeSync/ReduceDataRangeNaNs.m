function [xred,mx,sdx,linfit] = ReduceDataRangeNaNs(x,valid)
% reduce range of data with NaNs by standardization, followed by detrending
%
% [xred,mx,sdx,linfit] = ReduceDataRange(x,valid)
%
% x: input data
% valid: mask of valid data in x (OPTIONAL)
%        if valid not passed in, it's generated internally
%
% xred: range-reduced data
% mx: mean of input data
% sdx: standard deviation of input data
% linfit: linear fit parameters

% generate valid if not passed in
if nargin < 2
    valid = ~isnan(x);
end

xvalid = x(valid);

% get mean of valid input data
mx = mean(xvalid);
sdx = std(xvalid);

% check for non-zero data range
% 0 data range means constant

if max(xvalid) - min(xvalid) ~= 0

    % standardize data
    xred = (x - mx) / sdx;

    % generate a trend using valid data
    invec = 1:length(x);

    valid_ind = invec(valid);

    linfit = polyfit(valid_ind',xred(valid),1);

    % remove trend
    xred = xred - (polyval(linfit,invec))';

else
    xred = x - mx;
    linfit = [];
end

