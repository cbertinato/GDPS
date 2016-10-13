function data = FilterDePrep(prepped)
% removes filter prepping (FIR or FFT)
%
% data = FilterDePrep(prepped)
% 
% prepped: structure containing prepped data
% prepped.data: data vector
% prepped.norig: length of original data
% prepped.padl: left padding
% prepped.padr: right padding
% prepped.miss: logical vector of missing data in original
%
% data: data vector de-prepped

data = prepped.data(prepped.padl+1:prepped.padl+prepped.norig);

data(prepped.miss) = NaN;



