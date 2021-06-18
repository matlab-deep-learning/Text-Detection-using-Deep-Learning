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
    out = cell(2,1);
    outputNames = {'Conv_118','Relu_109'};
    [out{:}] = craftObj.predict(dlInput,'Outputs',outputNames);
end

