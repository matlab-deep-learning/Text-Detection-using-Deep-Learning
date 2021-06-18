classdef(SharedTestFixtures = {DownloadPretrainedCRAFTFixture}) tload < matlab.unittest.TestCase
    % Test for loading the downloaded model.
    
    % Copyright 2021 The MathWorks, Inc.
    
    % The shared test fixture DownloadPretrainedCRAFTFixture calls
    % downloadPretrainedCRAFT. Here we check that the properties of
    % downloaded model.
    
    properties        
        DataDir = fullfile(getRepoRoot(),'model');        
    end
    
    methods(Test)
        function verifyModelAndFields(test)
            % Test point to verify the fields of the downloaded models are
            % as expected.
                                    
            loadedModel = load(fullfile(test.DataDir,'craftNet.mat'));
            model = loadedModel.craftNet;
            test.verifyClass(model,'dlnetwork');
            test.verifyEqual(numel(model.Layers),63);
            test.verifyEqual(size(model.Connections),[66 2])
            test.verifyEqual(model.InputNames,{'Input_input'});
            test.verifyEqual(model.OutputNames,{'Conv_118'});
        end        
    end
end