clear all;

% Input images
Inimg = imread('/Users/Han Xinyu/OneDrive - University College London/Desktop/Dissertation/Images/Post3/20210125_1109.jpg');
Baseimg= imread('/Users/Han Xinyu/OneDrive - University College London/Desktop/Dissertation/Images/Post3/20210205_1106.jpg');

% Show together
figure;
subplot(1,2,1),imshow(Inimg);
subplot(1,2,2),imshow(Baseimg);

% Select features (control points)
% [selectedMovingPoints,selectedFixedPoints] = cpselect(Inimg,Baseimg,'Wait',true);
% cpselect(Inimg,Baseimg)

load post3_fixed.mat
load post3_moving.mat
 
% % Registration
tform=fitgeotrans(movingPoints,fixedPoints,'projective');
Iout=imwarp(Inimg,tform);

% Result
figure;
subplot(1,2,1),imshow(Iout);
subplot(1,2,2),imshow(Baseimg);

C=imfuse(Iout,Baseimg,'blend');
figure;
imshow(C);
