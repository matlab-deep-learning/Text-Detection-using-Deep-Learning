function out = craftPredict(matFile,image)
    %#codegen
    
    % Copyright 2021 The MathWorks, Inc.
    
    % Convert input to dlarray
    dlInput = dlarray(image,'SSCB');
    
    persistent craftObj;
    
    if isempty(craftObj)
    craftObj = coder.loadDeepLearningNetwork(matFile);
    end
    
    % Pass input
    out = craftObj.predict(dlInput);
end

