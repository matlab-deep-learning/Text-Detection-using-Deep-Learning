function [nLabels, labels, stats] = connectedComponents(textScoreComb,connectivity)
    % This function computes the connected components labeled image and
    % statistics output for each label.
    
    % Copyright 2021 The MathWorks, Inc.

    % compute connected components 
    CC = bwconncomp(textScoreComb,connectivity);

    % number of connected components in image
    nLabels = CC.NumObjects;

    % compute label matrix to label connected components in the image
    labels = labelmatrix(CC);

    % compute a set of properties like area, boundingbox for each connected component
    stats = regionprops(CC,'Area','BoundingBox','Centroid');
end
