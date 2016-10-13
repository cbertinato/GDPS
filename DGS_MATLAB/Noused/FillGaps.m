function filled = FillGaps(data,miss,pflen)
% fill interior NaN gaps in data
%
% filled = FillGaps(data,miss,pflen)
%
% data: data vector to be filled
% miss: vector of missing data indices
% pflen: prediction filter length to use (OPTIONAL)
%        default: 30
%
% filled: data with NaN gaps filled

if nargin < 4
    pflen = 30;
end

% fill interior gaps
filled = FillIntGapsRC(data,miss,pflen);
