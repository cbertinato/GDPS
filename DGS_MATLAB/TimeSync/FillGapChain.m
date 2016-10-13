function fill = FillGapChain(data,miss,valid,filt)
%
% fills missing values in a single gap chain
%
% fill = FillGapChain(data,miss,valid,filt)
%
% data: data values to be filled
% miss: mask of missing (NaN) values
% valid: mask of valid values
% filt: prediction error filter
%
% fill: filled values

% get some problem sizes
ndat = length(data);
nf = length(filt);

nrows = ndat + 1- nf;
ncols = sum(miss);

% set up index to position in missing data vector
missind = cumsum(miss);

sys = zeros(nrows, ncols);
rhs = zeros(nrows,1);

% loop over filter positions
w1 = 1;
w2 = nf;
for i=1:nrows

    % window into vectors
    datwin = data(w1:w2);
    misswin = miss(w1:w2);
    validwin = valid(w1:w2);
    missindwin = missind(w1:w2);

    % find right-hand side of system if there is any
    % valid data in window
    if sum(validwin) > 0
        rhs(i) = -dot(datwin(validwin),filt(validwin));
    end

    % fill system matrix
    sys(i,missindwin(misswin)) = filt(misswin);

    % move window along
    w1 = w1 + 1;
    w2 = w2 + 1;
end

% initialize filled with input data
fill = data;

% solve system for missing values
fill(miss) = sys \ rhs;
