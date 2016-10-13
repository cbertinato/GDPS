function [filled] = FillIntGapsRC(data,miss,pflen)
% fills interior NaN gaps in data
%
% [filled] = FillIntGaps(data,miss,valid,pflen)
%
% data: data vector to fill :first and last points are known to be
%       valid
% miss: mask vector of missing (NaN) data
% pflen: prediction filter length to use OPTIONAL
%        default: 30
%
% filled: filled output data

% set prediction filter length if not passed in
if nargin < 3
    pflen = 30;
end

data_iter = data;
data_iter(miss) = 0.0;
d1 = max(abs(data_iter));
it = 0;
while(true)
    % calculate unbiased prediction filter
    pf = UnbiasedPF(data_iter,pflen);

    % convert to prediction error filter
    pef = [1;-pf];
    peflen = pflen + 1;

    % find missing data gap starts and ends
    dmiss = diff(miss);
    gap_start = find(dmiss > 0) + 1;
    gap_end = find(dmiss < 0);

    % extend gaps by filter size to produce computation windows
    comp_window_start = gap_start - (peflen - 1);

    % avoid running off start of data
    comp_window_start(comp_window_start < 1) = 1;

    ndata = length(data);
    comp_window_end = gap_end + (peflen - 1);

    % avoid running off end of data
    comp_window_end(comp_window_end > ndata) = ndata;

    % use starts and ends of windows to set up chains
    % windows may overlap
    blocks = zeros(ndata,1);
    n_wind = length(comp_window_start);
    for w=1:n_wind
        blocks(comp_window_start(w):comp_window_end(w)) = 1;
    end

    % find start and ends of gap chains
    dblocks = diff(blocks);
    chain_start = find(dblocks > 0) + 1;
    if blocks(1) == 1
        chain_start = [1;chain_start];
    end
    chain_end  = find(dblocks < 0);
    if blocks(ndata) == 1
        chain_end = [chain_end ; ndata];
    end

    n_chain = length(chain_start);

    % loop and fill each chain
    filled = data_iter;
    for c=1:n_chain;
        cs = chain_start(c);
        ce = chain_end(c);

        filled(cs:ce) = FillGapChain(data(cs:ce),miss(cs:ce),~miss(cs:ce),...
            pef);
    end
    delta = filled-data_iter;
    it = it + 1;
    if abs(max(delta)) < 10*eps*d1 || it > 10
        break
    end
    data_iter = filled;
    
end
