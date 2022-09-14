%% Train A Semantic Segmentation Network 7501000

gpuDevice(1)

% Load the training data
dataSetDir = ['C:/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Script/Semantic Segmentation'];
imageDir = fullfile(dataSetDir,'BPP3_surfprojMRI_label7501000_resize');
labelDir = fullfile(dataSetDir,'BPP3Label_7501000','PixelLabelData');

% Create an image datastore for the images
imds = imageDatastore(imageDir);

% Create a pixelLabelDatastore for the ground truth pixel labels
%classNames = ["sea","rock"];
%classNames = ["sea","rock","bank","treeline","sky"];
classNames = ["sky","sandandbank","water","rock","treeline"];
%labelIDs   = [1 2];
labelIDs = [1 2 3 4 5];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

% Visualize training images and ground truth pixel labels
% I = read(imds);
% C = read(pxds);
% 
% I = imresize(I,5);
% L = imresize(uint8(C{1}),5);
% imshowpair(I,L,'montage')

% Create a semantic segmentation network
numFilters = 64;
filterSize = 3;
numClasses = 5;
layers = [
    imageInputLayer([750 1000 3])
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
    %transposedConv2dLayer(4,numFilters,'Stride',2);
    convolution2dLayer(1,numClasses);
    softmaxLayer()
    pixelClassificationLayer()
    ];

% Setup training options
opts = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-5, ...
    'MaxEpochs',100, ...
    'shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'MiniBatchSize',1);

% Combine the image and pixel label datastore for training
trainingData = combine(imds,pxds);

% Train the network
net = trainNetwork(trainingData,layers,opts);

% Read and display a test image
testImage = imread(['C:/Users/Han Xinyu/OneDrive - University College' ...
    ' London/Desktop/Dissertation/Script/Semantic Segmentation/' ...
    'BPP3_surfprojMRI_label7501000_resize/20210213_1226suprc.tif']);
imshow(testImage)

% Segment the test image and display the results
C = semanticseg(testImage,net);
cmap = camColorMap;
B = labeloverlay(testImage,C,'Colormap',cmap,'Transparency',0.4);
imshow(B)
LabelColorbar(cmap, classNames);

%% Train A Semantic Segmentation Network 300400
% Load the training data
dataSetDir = ['C:/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Script/Semantic Segmentation'];
imageDir = fullfile(dataSetDir,'BPP3_siftproj_nocp2_down5');
labelDir = fullfile(dataSetDir,'BPP3Label_300400_5','PixelLabelData');

% Create an image datastore for the images
imds = imageDatastore(imageDir);

% Create a pixelLabelDatastore for the ground truth pixel labels
%classNames = ["sea","rock"];
classNames = ["sea","rock","bank","treeline","sky"];
%labelIDs   = [1 2];
labelIDs   = [1 2 3 4 5];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

% Visualize training images and ground truth pixel labels
% I = read(imds);
% C = read(pxds);
% 
% I = imresize(I,5);
% L = imresize(uint8(C{1}),5);
% imshowpair(I,L,'montage')

% Create a semantic segmentation network
numFilters = 64;
filterSize = 3;
numClasses = 5;
layers = [
    imageInputLayer([300 400 3])
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
    %transposedConv2dLayer(4,numFilters,'Stride',2);
    convolution2dLayer(1,numClasses);
    softmaxLayer()
    pixelClassificationLayer()
    ];

% Setup training options
opts = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-5, ...
    'MaxEpochs',100, ...
    'shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'MiniBatchSize',64);

% Combine the image and pixel label datastore for training
trainingData = combine(imds,pxds);

% Train the network
net = trainNetwork(trainingData,layers,opts);

% Read and display a test image
testImage = imread(['C:/Users/Han Xinyu/OneDrive - University College' ...
    ' London/Desktop/Dissertation/Results/BPP3_siftproj_nocp2_down5' ...
    '/20210213_1226siprlow.tif']);
imshow(testImage)

% Segment the test image and display the results
C = semanticseg(testImage,net);
cmap = camColorMap;
B = labeloverlay(testImage,C,'Colormap',cmap,'Transparency',0.4);
imshow(B)
LabelColorbar(cmap, classNames);


%%
function cmap = camColorMap()
% Define the colormap used by CamVid dataset.

% % 7501000
% cmap = [
%     0 0.447 0.741       % sky
%     1 1 0.0667          % sandandbank
%     0 0 1               % water
%     0.502 0.502 0.502   % rock
%     0 1 0               % treeline
%     ];

% % 300400
% cmap = [
%     0 0.447 0.741       % sea
%     1 0 1               % rock
%     0.929 0.694 0.125   % bank
%     0 1 0               % treeline
%     0.0588 1 1          % sky
%     ];

% 300400
cmap = [
    0 0 1               % water
    0.502 0.502 0.502   % rock
    1 1 0.0667          % sandandbank
    0 1 0               % treeline
    0 0.447 0.741       % sky
    ];

% Normalize between [0 1].
% cmap = cmap ./ 255;
end

%%
function LabelColorbar(cmap, classNames)
% Add a colorbar to the current axis. The colorbar is formatted
% to display the class names with the color.

colormap(gca,cmap)

% Add colorbar to current figure.
c = colorbar('peer', gca);

% Use class names for tick marks.
c.TickLabels = classNames;
numClasses = size(cmap,1);

% Center tick labels.
c.Ticks = 1/(numClasses*2):1/numClasses:1;

% Remove tick mark.
c.TickLength = 0;
end