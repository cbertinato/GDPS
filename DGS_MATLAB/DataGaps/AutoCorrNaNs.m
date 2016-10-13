function normxc = AutoCorrNaNs(x,maxlag)
% computes autocorrelations for data with NaNs
%
% normxc = AutoCorrNaNs(x,maxlag)
%
% x: data vector
% maxlag: maximum lag to compute
%
% normxc: normalized autocorrelation
%         maxlag+1 values, normalized to normc(1)=1
%         note this is for non-negative lags only

xc = zeros(maxlag+1,1);

%loop over lags
for lag=1:maxlag+1
    
    % compute vector of products
    prods = x(1:end-lag+1) .* x(lag:end);
    
    % only use valid (not NaN) products
    valid = ~isnan(prods);
    
    validcount = sum(valid);
    
    % only do if there are valid products
    if validcount > 0
        xc(lag) = sum(prods(valid)) / validcount;
    end
    
end

% normalize
normval = 1 / xc(1);

normxc = xc * normval;
