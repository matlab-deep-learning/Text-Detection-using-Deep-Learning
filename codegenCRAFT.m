%% Code Generation for CRAFT
% The following code demonstrates code generation for a pre-trained 
% CRAFT text detection network.

%% Setup
% Add path to the source directory.
addpath('src');

%% Download the Pre-trained Network
helper.downloadPretrainedCRAFT;

%% Read and Preprocess Input Image
% Read input image
orgImage = imread('businessCard.png');

% Preprocess the image
[image, imageScale] = helper.preprocess(orgImage);

% Provide location of the mat file of the trained network
matFile = 'model/craftNet.mat';
%% Run MEX code generation
% The craft_predict.m is entry-point function that takes an input 
% image and give output as region and affinity score map.  The function 
% uses a persistent object craftObj to 
% load the dlnetwork object and reuses the persistent object for prediction 
% on subsequent calls.
%
% To generate CUDA code for the craftPredict entry-point function, 
% create a GPU code configuration object for a MEX target and set the 
% target language to C++. 
% 
% Use the coder.DeepLearningConfig (GPU Coder) function to create a CuDNN 
% deep learning configuration object and assign it to the DeepLearningConfig 
% property of the GPU code configuration object. 
% 
% Run the codegen command.

cfg = coder.gpuConfig('mex');
cfg.TargetLang = 'C++';
cfg.DeepLearningConfig = coder.DeepLearningConfig('cudnn');
args = {coder.Constant(matFile), im2single(image)};
codegen -config cfg craftPredict -args args -report

%% Run Generated MEX

% Call craft_predict_mex on the input image
out = craftPredict_mex(matFile,im2single(image));

% apply post-processing on the output
boundingBoxes = helper.postprocess(out,imageScale);

% Visualize results
outImg = insertShape(orgImage,'Polygon',boundingBoxes,'LineWidth',5,'Color',"yellow");
figure, imshow(outImg)

% Copyright 2021 The MathWorks, Inc.
