# Text Detection using Deep Learning

This repository implements a pretrained Character Region Awareness For Text detection (CRAFT) [1] model in MATLAB&reg;.

Requirements
------------  

- MATLAB R2021a or later
- Deep Learning Toolbox&trade;
- Computer Vision Toolbox&trade;

Overview
--------

This repository implements CRAFT with VGG-16 as backbone. The network is trained on various scene text detection datasets with text in English, Korean, Italian, French, Arabic, German and Bangla (Indian). 

CRAFT uses a convolutional neural network to produce two outputs, region score, and affinity score. The region score localizes individual characters in the image, and the affinity score groups each character into a single instance. The character-level region awareness mechanism helps in detecting texts of various shapes such as long, curved, and arbitrarily shaped texts.

Getting Started
---------------
Download or clone this repository to your machine and open it in MATLAB.
### Setup
Add path to the source directory.

`addpath('src');`

### Load the pretrained network
Use the below helper to download the pretrained network.
```
model = helper.downloadPretrainedCRAFT;
craftNet = model.craftNet;
```

Detect Objects Using Pretrained CRAFT
---------------------------------------

```
% Read test image.
  orgImg = imread('businessCard.png');

% Pre-process the image
  [image, imageScale] = helper.preprocess(orgImg);

% Output from CRAFT network for the given image
  out = predict(craftNet,dlarray(image,'SSCB'));
    
% Postprocess the output
  boundingBoxes = helper.postprocess(out,imageScale);
    
% Visualize results
  outImg = insertShape(orgImg,'Polygon',boundingBoxes,'LineWidth',5,'Color',"yellow");
  figure; imshow(outImg);
```

<img src="images/business_card.png" alt ="image" width="550" height="350"/>

If the image contains text in arbitrary shape then change the value of `polygonText` variable in `src/+helper/postprocess.m` to `true`.

The CRAFT network has three tunable parameters, text threshold, low text and link threshold. Tune these hyperparameters in `src/+helper/postprocess.m` to get better results. 
- Text threshold: Higher value indicates that character in image has to be more clear to be considered as text.
- Low text: Higher value will give less boundary space around characters.
- Link threshold: Higher value will increase the amount by which two characters will be considered as single word.

Code Generation for CRAFT
---------------------------------------
Code generation enables you to generate code and deploy CRAFT on multiple embedded platforms.

Run `codegenCRAFT.m`. This script calls the `craftPredict.m` entry point function and generate CUDA code for it. It will run the generated MEX and gives output.
| Model | Inference Speed (FPS) | 
| ------ | ------ | 
| CRAFT w/o codegen | 3.044 |
| CRAFT with codegen | 5.356 |

Note: Performance (in FPS) is measured on a TITAN-RTX GPU using 672x992 image.

Text Recognition using OCR + CRAFT
----------------------------------

Output of CRAFT network generates the quadrilateral-shape bounding boxes that can be passed to `ocr` function as region of interest (roi) for text recognition applications.

```
% Convert boundingBoxes format from [x1 y1 ... x8 y8] to [x y w h].
  roi = [];
  for i = 1:size(boundingBoxes,1)
    w = norm(boundingBoxes(i,[3 4]) - boundingBoxes(i,[1 2]));
    h = norm(boundingBoxes(i,[5 6]) - boundingBoxes(i,[3 4]));
    roi = [roi; [boundingBoxes(i,1) boundingBoxes(i,2) w h]];
  end

% Binarizing the image before using OCR for better results.
  I = rgb2gray(orgImg);
  BW = imbinarize(I, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.5);
  figure; imshow(BW);

% OCR this image using region-of-interest for OCR to avoid processing non-text background.
  txt = ocr(BW,roi,'TextLayout','word');
  word =[];
  idx = [];
  for i = 1:size(roi,1)
      if ~isempty(txt(i,1).Words)
              [~,index] = max(txt(i,1).WordConfidences);
              word = [word; txt(i,1).Words(index)];
              idx = [idx i];  
      end
  end
  Iocr = insertObjectAnnotation(orgImg, 'rectangle',roi(idx,:),word);
  figure; imshow(Iocr);
```

<img src="images/ocr_result.jpg" alt ="image" width="550" height="350"/>

Accuracy
---------

| Dataset | Recall | Precision  | Hmean |
| ------ | ------ | ------ | ------ |
| ICDAR2013[2] | 92.60 | 91.84 | 91.81 |
| ICDAR2017[3] | 62.29 | 78.68 | 69.53 |

CRAFT Network Architecture
--------------------------

![alt text](images/craft_architecture.PNG?raw=true)

The architecture of CRAFT is composed of VGG-16 as backbone and skip connections in the decoding part, similar to U-net to aggregate low-level features. The UpConv blocks are made of convolutional and batch normalization layers. These blocks are used to perform upsampling.

The pretrained CRAFT network takes the image as input and generates the output feature map with two channels that correspond to region score and affinity score. The region score represents the probability that the given pixel is the center of the character, and the affinity score represents the center probability of the space between adjacent characters. 



Publication
-----------

[1] Baek, Y., Lee, B., Han, D., Yun, S. and Lee, H., 2019. Character region awareness for text detection. In Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition (pp. 9365-9374).

[2] https://rrc.cvc.uab.es/?ch=2&com=downloads

[3] https://rrc.cvc.uab.es/?ch=8&com=downloads

Copyright 2021 The MathWorks, Inc.
