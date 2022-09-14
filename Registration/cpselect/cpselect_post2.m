clear all;

% Input images
Inimg = imread('/Users/Han Xinyu/Desktop/Dissertation/Images/Post2/20201216_1225.jpg');
Baseimg= imread('/Users/Han Xinyu/Desktop/Dissertation/Images/Post2/20210422_0957.jpg');

% Show together
figure;
subplot(1,2,1),imshow(Inimg);
subplot(1,2,2),imshow(Baseimg);

% Select features (control points)
% [selectedMovingPoints,selectedFixedPoints] = cpselect(Inimg,Baseimg,'Wait',true);
% cpselect(Inimg,Baseimg)

load post2_fixed.mat
load post2_moving.mat

% Registration
tform=fitgeotrans(movingPoints,fixedPoints,'affine');
Iout=imwarp(Inimg,tform);

% Result
figure;
subplot(1,2,1),imshow(Iout);
subplot(1,2,2),imshow(Baseimg);
