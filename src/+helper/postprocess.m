function boundingBoxes = postprocess(out,imageScale)
    % This function postprocesses the output.

    % Copyright 2021 The MathWorks, Inc.
    
    % tunable parameters
    
    % text confidence threshold: decide which region to be considered as text
    textThreshold = 0.4; 
    % text low-bound score: decide the boundary space around the character 
    lowText  = 0.2; 
    % link confidence threshold: decide the distance between two characters 
    % to be considered as single word
    linkThreshold = 0.2; 
    % Boolean indicating whether the network is being evaluated for
    % image containing text in arbitrary shape. If polygonText is true, 
    % polygonal shape bounding boxes will be generated 
    % having 14 coordinates. Otherwise, quadrilateral shape bounding boxes
    % will be generated having 4 coordinates.
    polygonText = false;

    output = extractdata(squeeze(out));

    % region and affinity score maps
    regionScore = output(:,:,1);
    affinityScore= output(:,:,2);
    
    % generate quadrilateral shape bounding boxes
    [nLabels,labels, boxes, mapper] = helper.getQuadBoxes(regionScore, affinityScore, textThreshold, linkThreshold, lowText);
    % coordinate adjustment
    bboxes = helper.adjustBBoxCoordinates(boxes, imageScale);
    if polygonText 
        % generate polygon shape bounding boxes
        polyBox = helper.getPolygonBoxes(boxes, labels, mapper);
        polygon = cell(size(polyBox,1),1);
        polys = helper.adjustBBoxCoordinates(polyBox, imageScale);
        for i = 1:size(polys,1)
            if isnan(polys(i,:))
               polygon{i,:}=bboxes(i,:);
               continue;
            end
            polygon{i,:}=polys(i,:);
        end
        boundingBoxes = polygon;
    else
        boundingBoxes = bboxes;
    end
end