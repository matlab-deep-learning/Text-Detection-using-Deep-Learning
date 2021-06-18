function [nLabels, labels, bboxes, mapper] = getQuadBoxes(textmap, linkmap, textThreshold, linkThreshold, lowText)
    % This function generates Quadrilateral shape bounding boxes.

    % Copyright 2021 The Mathworks, Inc.

    bboxes = [];
    [imgH, imgW] = size(textmap);
    mapper = [];
    
    % labeling method
    regionScore = imbinarize(textmap,lowText);
    affinityScore = imbinarize(linkmap, linkThreshold);
    
    textScoreComb = regionScore + affinityScore;
    textScoreComb(textScoreComb>1) = 1;
    textScoreComb(textScoreComb<0) = 0; 
    
    [nLabels, labels, stats] = helper.connectedComponents(textScoreComb,4);

    for k = 1:nLabels
        % size filtering
        sizes = stats(k).Area;
        if sizes < 10
            continue
        end
        
        % thresholding
        if max(textmap(labels==k)) < textThreshold
            continue
        end
        
        % make segmentation map
        segmap = zeros(size(textmap));
        segmap(labels==k) = 255;
        segmap(affinityScore==1 & regionScore==0) = 0; % remove link area
        x = ceil(stats(k).BoundingBox(1)); y = ceil(stats(k).BoundingBox(2)); 
        w = stats(k).BoundingBox(3); h = stats(k).BoundingBox(4);
        niter = fix(sqrt(sizes * min(w, h) / (w * h)) * 2);
        sx = x - niter; ex = x + w + niter + 1;
        sy = y - niter; ey = y + h+ niter + 1;
        % boundary check
        if sx < 1
            sx = 1;
        end
        if sy < 1
            sy = 1;
        end
        if ex >= imgW
            ex = imgW;
        end
        if ey >= imgH
            ey = imgH;
        end
        kernel = strel('rectangle',[niter + 1, niter + 1]);
        segmap(sy:ey, sx:ex) = imdilate(segmap(sy:ey, sx:ex), kernel);
        
        % make box
        [i j] = find(segmap~=0);
        indices = [i j];
    
        npContours = transpose(circshift((indices'), 1, 1));
        bb = helper.minBoundingBox(npContours');
    
       % align diamond-shape
       w = norm(bb(:,1) - bb(:,2));
       h = norm(bb(:,2) - bb(:,3));
       boxRatio = max(w, h) / (min(w, h) + 1e-5);
       if abs(1 - boxRatio) <= 0.1
           l = min(npContours(:,1)); r = max(npContours(:,1));
           t = min(npContours(:,2)); b = max(npContours(:,2));
           bb = [l t; r t;r b; l b];
           bb = transpose(bb);
       end  
    
    %   make clock-wise order
        [~,startidx] = min(sum(bb,1));
        bb = circshift(bb, 4-(startidx-1), 2);
        boxes = reshape(bb,1,8);
        bboxes = [bboxes; boxes];
        mapper = [mapper k]; % list of connected components/labels for valid text areas
    
   end 
end
