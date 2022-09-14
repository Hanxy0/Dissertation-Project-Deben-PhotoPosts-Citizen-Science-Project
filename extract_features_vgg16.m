%
%% Testing of a single image
% data enhancement + feature extraction + maximum activation layer display

% Load test image
im = imread(['C:/Users/Han Xinyu/OneDrive - University College London/' ...
    'Desktop/Dissertation/Images/Post3/20210125_1109.jpg']);
%imshow(im)

imgSize = size(im);
imgSize = imgSize(1:2);

% Load pretrained network
net = vgg16;
%analyzeNetwork(net);

% Inspect the first layer
net.Layers(1)

% Inspect the last layer
net.Layers(end)

% imageSize = net.Layers(1).InputSize;
% augmentedTrainingSet = augmentedImageDatastore(imageSize, trainingSet, 'ColorPreprocessing', 'gray2rgb');

% Get the network weights for the second convolutional layer
w1 = net.Layers(2).Weights;

% Scale and resize the weights for visualization
w1 = mat2gray(w1);
w1 = imresize(w1,5); 

% Display a montage of network weights. There are 96 individual sets of weights in the first layer.
figure(1)
montage(w1)
title('First convolutional layer weights')

featureLayer = 'conv1_1';
act1 = activations(net, im, featureLayer);

% To show these activations using the imtile function, reshape the array from 3D to 4D
sz = size(act1);
act1 = reshape(act1,[sz(1) sz(2) 1 sz(3)]);

I = imtile(mat2gray(act1),'GridSize',[8 8]);
figure(2)
imshow(I)

% Find the Strongest Activation Channel
[maxValue,maxValueIndex] = max(max(max(act1)));
act1chMax = act1(:,:,:,maxValueIndex);
act1chMax = mat2gray(act1chMax);
act1chMax = imresize(act1chMax,imgSize);

I = imtile({im,act1chMax});
figure(3)
imshow(I)

% Investigate a specific deep layer
act3 = activations(net,im,'conv1_2');
sz = size(act3);
act3 = reshape(act3,[sz(1) sz(2) 1 sz(3)]);

I = imtile(imresize(mat2gray(act3),[64 64]),'GridSize',[6 8]);
figure(4)
imshow(I)

[maxValue3,maxValueIndex3] = max(max(max(act3)));
act3chMax = act3(:,:,:,maxValueIndex3);
figure(5)
imshow(imresize(mat2gray(act3chMax),imgSize))

% Investigate specific access routes
I = imtile(imresize(mat2gray(act3(:,:,:,[8 40])),imgSize));
figure(6)
imshow(I)


act6relu = activations(net,im,'relu1_2');
sz = size(act6relu);
act6relu = reshape(act6relu,[sz(1) sz(2) 1 sz(3)]);

I = imtile(imresize(mat2gray(act6relu),[64 64]),'GridSize',[6 8]);
figure(7);
imshow(I)

I = imtile(imresize(mat2gray(act6relu(:,:,:,[8 40])),imgSize));
figure(3);
imshow(I)


% Test Whether a Channel Recognizes Interested features (sea surface)
imlowtide = imread(['C:/Users/Han Xinyu/OneDrive - University College London/' ...
    'Desktop/Dissertation/Images/Post3/20210205_1106.jpg']); 
%imshow(imlowtide)

act6Closed = activations(net,imlowtide,'relu1_2');
sz = size(act6Closed);
act6Closed = reshape(act6Closed,[sz(1),sz(2),1,sz(3)]);

I = imtile(imresize(mat2gray(act6Closed(:,:,:,[8 40])),imgSize));
figure(8)
imshow(I)

% Plot the images and activations in one figure
channelslowtide = repmat(imresize(mat2gray(act6Closed(:,:,:,[8 40])),imgSize),[1 1 3]);
channelsnormal = repmat(imresize(mat2gray(act6relu(:,:,:,[8 40])),imgSize),[1 1 3]);
I = imtile(cat(4,im,channelsnormal*255,imlowtide,channelslowtide*255));
figure(9);
imshow(I)
title('Input Image, Channel 8, Channel 40');
