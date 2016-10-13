function [line1samp, line2samp] = FindLineIntersections(l1x,l1y,l2x,l2y)
% FindLineIntersections: finds along-line samples of line intersections
%
% [line1samp, line2samp] = FindLineIntersections(l1x,l1y,l2x,l2y)
%
% l1x: line 1 x-coordinates
% l1y: line 1 y-coordinates
% l2x: line 2 x-coordinates
% l2y: line 2 y-coordinates
%
% line1samp: sample indices of intersections along line 1
% line2samp: sample indices of intersections along line 2

% find x,y coordinates of intersections
[xint,yint] = curveintersect(l1x,l1y,l2x,l2y);

% punt if they don't intersect
if isempty(xint)
    line1samp = [];
    line2samp = [];
    return
end

% loop over intersections and find sample indices
nint = length(xint);
line1samp = zeros(nint,1);
line2samp = zeros(nint,1);

for i=1:nint
    line1samp(i)= FindCurveInterval(l1x,l1y,xint(i),yint(i));
    line2samp(i)= FindCurveInterval(l2x,l2y,xint(i),yint(i));
end
    