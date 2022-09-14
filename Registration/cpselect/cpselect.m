% Read the reference image
ortho = imread('/Users/Han Xinyu/OneDrive - University College London/Desktop/Dissertation/Images/Post3/20210125_1109.jpg');
imshow(ortho)
text(size(ortho,2),size(ortho,1)+15, ...
    'Image courtesy of Massachusetts Executive Office of Environmental Affairs', ...
    'FontSize',7,'HorizontalAlignment','right');
% Read the distorted image
unregistered = imread('/Users/Han Xinyu/OneDrive - University College London/Desktop/Dissertation/Images/Post3/20210205_1106.jpg');
imshow(unregistered)
text(size(unregistered,2),size(unregistered,1)+15, ...
    'Image courtesy of mPower3/Emerge', ...
    'FontSize',7,'HorizontalAlignment','right');
% % Select Control Point Pairs
% [mp,fp] = cpselect(unregistered,ortho,'Wait',true);

load post3_fixed.mat
load post3_moving.mat

% Infer Geometric Transformation
t = fitgeotrans(movingPoints,fixedPoints,'projective');
% Transform Unregistered Image
Rfixed = imref2d(size(ortho));
registered = imwarp(unregistered,t,'OutputView',Rfixed);
% result of the registration (overlaying the transformed image over the original orthophoto)
imshowpair(ortho,registered,'blend')