function out = MissNaNs(in,tind,ndata)
out = NaN(ndata,1);
out(tind) = in;

