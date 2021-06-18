function [image, ratio] = preprocess(I)
    % This function preprocesses the input image.

    % Copyright 2021 The Mathworks, Inc.
    
    % adjust magRatio and canvasSize for better results
    % image magnification ratio
    magRatio = 1.5;
    % image size for inference
    canvasSize = 4000;
    
    % handling gray image
    if numel(size(I)) == 2
        I = repmat(I, [1, 1, 3]);
    end
    
    I = im2single(I);
    [height, width, channel] = size(I);
    
    % magnify image size
    targetSize = magRatio * max(height, width);
    
    % set original image size
    if targetSize > canvasSize
        targetSize = canvasSize;
    end
    ratio = targetSize / max(height, width);
    targetH = fix(single(height * ratio));
    targetW = fix(single(width * ratio));
    processedImage = imresize(I, [targetH targetW], 'bilinear');
    
    % make canvas and paste image
    targetH32 = targetH; 
    targetW32 = targetW;
    if mod(targetH, 32) ~= 0
        targetH32 = targetH + (32 - mod(targetH, 32));
    end
    if mod(targetW, 32) ~= 0
        targetW32 = targetW + (32 - mod(targetW, 32));
    end
    
    % pre-processed image of size [h w]
    image = zeros(targetH32, targetW32, channel);
    image(1:targetH, 1:targetW, :) = processedImage;
    
end
