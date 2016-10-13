function RFFT = RealFFT(ftsig)
% enforces real-FFT symmetry on an FFT
%
% RFFT = RealFFT(ftsig)
%
% ftsig: complex input
% RFFT: real FFT output

RFFT = ftsig(:);

N = length(RFFT);
nnyq = (N / 2) + 1;

% turn off whining about non-integer index for odd lengths
warning('off','MATLAB:colon:nonIntegerIndex')

RFFT(nnyq+1:N) = flipud(conj(RFFT(2:nnyq-1)));

warning('on','MATLAB:colon:nonIntegerIndex')

