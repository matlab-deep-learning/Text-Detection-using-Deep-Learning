function bb = minBoundingBox(X)
% This function compute a rotated rectangle of the minimum area enclosing
% the input 2D point set.

% compute the convex hull (CH is a 2*k matrix subset of X)
k = convhull(X(1,:),X(2,:));
CH = X(:,k);
% compute the angle to test, which are the angle of the CH edges as:
%   "one side of the bounding box contains an edge of the convex hull"
E = diff(CH,1,2);           % CH edges
T = atan2(E(2,:),E(1,:));   % angle of CH edges (used for rotation)
T = unique(mod(T,pi/2));    % reduced to the unique set of first quadrant angles
% create rotation matrix which contains
% the 2x2 rotation matrices for *all* angles in T
% R is a 2n*2 matrix
R = cos( reshape(repmat(T,2,2),2*length(T),2) ... % duplicate angles in T
       + repmat([0 -pi ; pi 0]/2,length(T),1));   % shift angle to convert sine in cosine
% rotate CH by all angles
RCH = R*CH;
% compute border size  [w1;h1;w2;h2;....;wn;hn]
% and area of bounding box for all possible edges
bsize = max(RCH,[],2) - min(RCH,[],2);
area  = prod(reshape(bsize,2,length(bsize)/2));
% find minimal area, thus the index of the angle in T 
[~,i] = min(area);
% compute the bound (min and max) on the rotated frame
Rf    = R(2*i+[-1 0],:);   % rotated frame
bound = Rf * CH;           % project CH on the rotated frame
bmin  = min(bound,[],2);
bmax  = max(bound,[],2);
% compute the corner of the bounding box
Rf = Rf';
bb(:,4) = bmax(1)*Rf(:,1) + bmin(2)*Rf(:,2);
bb(:,3) = bmin(1)*Rf(:,1) + bmin(2)*Rf(:,2);
bb(:,2) = bmin(1)*Rf(:,1) + bmax(2)*Rf(:,2);
bb(:,1) = bmax(1)*Rf(:,1) + bmax(2)*Rf(:,2);
