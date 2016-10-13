function varargout=gaussian_filter(t,y,filtL,n)
%this function returns data filtered n times with a time domain gaussian 
%filter of length, filtL
%
%USAGE 
%   gaussian_filter(t,y,filtL,n); % this will plot the result
%   Y=gaussian_filter(t,y,filtL,n);
%   [Y,T]=gaussian_filter(t,y,filtL,n);
%
%INPUT
%   t ARRAY time in decimal seconds
%   y ARRAY data
%   filtL SCALAR filter length in seconds
%   n INTEGER number of times to apply the filter
%
%OUTPUT
%   Y ARRAY filtered data 
%   ti ARRAY time interpolated across gaps if needed
%
%NOTE
%   filtered data within one filter length of the ends should not be used
%
%CREATED by Sandra Preaux, May 25, 2011
%Modified to make sure t and y are row vectors, S.Preaux April 2014

%% Make sure inputs are row vectors
[r,c]=size(t); 
if r>c  %t is a column vector
    t=t'; %transpose t to a row vector
end
[r,c]=size(y);
if r>c %y is a column vector
    y=y'; %transpose y to a row vector
end
clear r c

%% make filter window
%check data rate
datarate=1/mode(floor(diff(t).*1000)./1000);

if datarate~=1
    %change filter length to acount for datarate
    filtL=filtL.*datarate;
end
%window length must be an odd integer
filtL=floor(filtL);
if mod(filtL,2)==0
    filtL=filtL+1;
end
%make appropriate filter window
fg=gausswin(filtL);
fg=(fg./sum(fg))';
%% check for data gaps - interpolate if necessary
ti=t(1):1/datarate:t(end);
if length(t)~=length(ti)
    Y=interp1(t,y,ti,'linear');
else
    Y=y;
end
%% apply filter
for i=1:n
    Y=convn(Y,fg,'same');
end

%%output
if nargout<1
    %plot data and filtered data
    figure;
    y_limits=[min(y) max(y)];
    h=plot(t,y,'b','DisplayName','Original Data');
    hold on;
    dn_str=sprintf('Data filtered %d x %d second Gaussian Filter',n,filtL-1);
    plot(t,Y,'k','LineWidth',3,'DisplayName',dn_str);
    ylim(y_limits);
    legend toggle
else
    varargout{1}=Y;
    varargout{2}=ti;
end