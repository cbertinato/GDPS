function shift_sig =  FTPhaseShift(sig,dt,tinc)

if nargin == 2
    tinc = 1.0;
end

if dt == 0
    shift_sig = sig;
    
else

    next = Next2357(length(sig)+120/tinc);
    pad = next - length(sig);
    padl = floor(pad / 2);
    padr = pad - padl;

    sigext = FFTFilterPrep(sig,padl,padr);

    ftsig = fft(sigext.data);

    nnyq = (next / 2) + 1;

    frqstep = 1 / (next * tinc);
    freq = (0:frqstep:1/(2*tinc))';

    ftsig(2:nnyq-1) = ftsig(2:nnyq-1) .*  ...
        exp(complex(zeros(nnyq-2,1),-2*pi*dt*freq(2:nnyq-1)));

    ftsig(nnyq) = 0 + 0i;

    ftsig = RealFFT(ftsig);

    sigext.data = ifft(ftsig);
    
    shift_sig = FilterDePrep(sigext);

end