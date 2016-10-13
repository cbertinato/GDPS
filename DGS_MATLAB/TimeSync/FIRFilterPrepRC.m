function prepped = FIRFilterPrepRC(data,padl,padr,pflen)
% preps data for applying an FIR filter
%
% prepped = FIRFilterPrep(data,padl,padr,pflen)
%
% data: data vector for prepping
% padl: number pf samples to add to left of data
% padr: number of samples to add to right of data
% pflen: prediction filter length to use (OPTIONAL)
%        default: 30
%
% prepped: output prepped data structure
% prepped.data: data vector
% prepped.norig: length of original data
% prepped.padl: left padding
% prepped.padr: right padding
% prepped.miss: logical vector of missing data in original
data = data(:);

norig = length(data);
datred = zeros(norig,1);

% set pflen if not passed
if nargin < 4
    pflen = 30;
end

% get vectors of missing and valid data in original
miss = isnan(data);
valid = ~miss;
firstv = find(valid,1,'first');
lastv = find(valid,1,'last');

if sum(miss(firstv:lastv)) == 0
    % no interior missing data
    % reduce data range
    [datred(firstv:lastv), mdat, sddat, linfit] =  ...
        ReduceDataRange(data(firstv:lastv));
else
    % there is interior missing data
    % reduce data range
    [datred(firstv:lastv), mdat, sddat, linfit] = ...
        ReduceDataRangeNaNs(data(firstv:lastv),valid(firstv:lastv));
    
    % fill interior gaps if reduced range data is not zero
    if max(datred(firstv:lastv)) - min(datred(firstv:lastv)) ~= 0
        datred(firstv:lastv) = FillIntGapsRC(datred(firstv:lastv),miss(firstv:lastv));
    end
end

% check for 0 data range: 0 means constant

if max(datred(firstv:lastv)) - min(datred(firstv:lastv)) ~= 0

    % not a constant: extrapolate data
    datred = PFExtrap(datred(firstv:lastv),padl+firstv-1,...
        padr+norig-lastv,pflen);

    % undo range reduction
    xeval = (1:length(datred)) - padl;

    datred = datred + polyval(linfit,xeval)';

    datred = (datred * sddat) + mdat;

    % it's a constant: just pad with zeros
else
    datred = zeros(padl+norig+padl,1) + mdat;
end

% fill output structure
prepped.data = datred;
copyback = [false(padl,1); valid ; false(padr,1)];
prepped.data(copyback) = data(valid);
prepped.norig = norig;
prepped.padl = padl;
prepped.padr = padr;
prepped.miss = miss;
