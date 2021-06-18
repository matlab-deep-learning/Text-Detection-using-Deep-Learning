function model = downloadPretrainedCRAFT()
% The downloadPretrainedEfficientDetD0 function downloads the pretrained
% CRAFT network.
%
% Copyright 2021 The MathWorks, Inc.

dataPath = 'model';
modelName = 'craftModel';
netFileFullPath = fullfile(dataPath, modelName);

% Add '.zip' extension to the data.
netFileFull = [netFileFullPath,'.zip'];

if ~exist(netFileFull,'file')
    fprintf(['Downloading pretrained', modelName ,'network.\n']);
    fprintf('This can take several minutes to download...\n');
    url = 'https://ssd.mathworks.com/supportfiles/vision/deeplearning/models/TextDetection/craftModel.zip';
    websave (netFileFullPath,url);
    unzip(netFileFullPath, dataPath);
    model = load([dataPath, '/craftNet.mat']);
else
    fprintf('Pretrained EfficientDet-D0 network already exists.\n\n');
    unzip(netFileFullPath, dataPath);
    model = load([dataPath, '/craftNet.mat']);
end
end
