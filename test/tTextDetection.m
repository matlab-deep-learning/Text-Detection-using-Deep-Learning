classdef(SharedTestFixtures = {DownloadPretrainedCRAFTFixture}) tTextDetection < matlab.unittest.TestCase
    % Test for TextDetection
    
    % Copyright 2021 The MathWorks, Inc.
    
    % The shared test fixture downloads the model. Here we check the
    % inference on the pretrained model.
    properties        
        RepoRoot = getRepoRoot;        
    end
    
    methods(Test)
        function exerciseDetection(test)            
            model = load(fullfile(test.RepoRoot,'model','craftNet.mat'));
            inpImage = imread('businessCard.png');
           

            expectedBBoxes = [161.3333, 61.3333,542.6667, 61.3333,542.6667,145.3333,161.3333,145.3333;
                169.3333,312.0000,192.0000,312.0000,192.0000,340.0000,169.3333,340.0000;
                170.6667,272.0000,218.6667,272.0000,218.6667,304.0000,170.6667,304.0000;
                170.6667,348.0000,260.0000,348.0000,260.0000,384.0000,170.6667,384.0000;
                170.6667,386.6667,228.0000,386.6667,228.0000,418.6667,170.6667,418.6667;
                170.6667,424.0000,416.0000,424.0000,416.0000,454.6667,170.6667,454.6667;
                196.0000,310.6667,270.6667,310.6667,270.6667,349.3333,196.0000,349.3333;
                217.6480,269.3688,363.4014,272.5033,362.6325,308.2573,216.8791,305.1228;
                261.3333,349.3333,308.0000,349.3333,308.0000,380.0000,261.3333,380.0000;
                270.6667,310.6667,314.6667,310.6667,314.6667,342.6667,270.6667,342.6667;
                309.3333,349.3333,465.3333,349.3333,465.3333,381.3333,309.3333,381.3333;
                314.6667,312.0000,381.3333,312.0000,381.3333,344.0000,314.6667,344.0000;
                364.0000,276.0000,408.0000,276.0000,408.0000,304.0000,364.0000,304.0000];
            %Pre process
            [image, imageScale] = helper.preprocess(inpImage);
           
            %Inferance
            out = predict(model.craftNet,dlarray(image,'SSCB'));

            %Post process to get the boundingBoxes
            boundingBoxes = helper.postprocess(out,imageScale);

            test.verifyEqual(boundingBoxes,expectedBBoxes,'AbsTol',double(1e-4));
        end      
    end
end
