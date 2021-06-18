function boxes = adjustBBoxCoordinates(boxes, imageScale)
    % This function gives final coordinates of bounding boxes.

    % Copyright 2021 The Mathworks, Inc.
    
    scale = 2 * (1/imageScale);
    if isempty(boxes)
        boxes = [0 0 0 0 0 0 0 0];
    else
        num_boxes = size(boxes,1);
        for k = 1:num_boxes
            if ~isnan(boxes(k,:))
                boxes(k,:) = boxes(k,:) * scale;
            end
        end
    end
end
