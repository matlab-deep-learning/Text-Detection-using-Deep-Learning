classdef(SharedTestFixtures = {DownloadPretrainedCRAFTFixture}) tdownloadPretrainedCRAFT < matlab.unittest.TestCase
    % Test for downloadPretrainedCRAFT
    
    % Copyright 2021 The MathWorks, Inc.
    
    % The shared test fixture DownloadPretrainedCRAFTFixture calls
    % tdownloadPretrainedCRAFT. Here we check that the downloaded files
    % exists in the appropriate location.
    
    properties        
        DataDir = fullfile(getRepoRoot(),'model');
    end
    
    methods(Test)
        function verifyDownloadedFilesExist(test)
            dataFileName = 'craftNet.mat';
            test.verifyTrue(isequal(exist(fullfile(test.DataDir,dataFileName),'file'),2));
        end
    end
end
