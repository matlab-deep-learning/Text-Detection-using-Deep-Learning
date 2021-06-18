classdef DownloadPretrainedCRAFTFixture < matlab.unittest.fixtures.Fixture
    % DownloadPretrainedCRAFTFixture   A fixture for calling 
    % downloadDownloadPretrainedCRAFT if necessary. This is to 
    % ensure that this function is only called once and only when tests 
    % need it. It also provides a teardown to return the test environment
    % to the expected state before testing.
    
    % Copyright 2021 The MathWorks, Inc
    
    properties(Constant)
        CRAFTDataDir = fullfile(getRepoRoot(),'model')
    end
    
    properties
        CRAFTExist (1,1) logical        
    end
    
    methods
        function setup(this) 
            import matlab.unittest.fixtures.CurrentFolderFixture;
            this.applyFixture(CurrentFolderFixture ...
                (getRepoRoot()));
            
            this.CRAFTExist = exist(fullfile(this.CRAFTDataDir,'craftNet.mat'),'file')==2;
            
            % Call this in eval to capture and drop any standard output
            % that we don't want polluting the test logs.
            if ~this.CRAFTExist
            	evalc('helper.downloadPretrainedCRAFT();');
            end       
        end
        
        function teardown(this)
            if this.CRAFTExist
            	delete(fullfile(this.CRAFTDataDir,'craftNet.mat'));
            end              
        end
    end
end
