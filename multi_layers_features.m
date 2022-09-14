%% Input using original image size
gpuDevice(1);

net = vgg16; % net could be altered

imageDIR = ['/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Images/Post3/'];
oFileHW = '20210125_1109.jpg';
oFileNhw = char(oFileHW);oFileNhw = oFileNhw(1:end-4);
orthoHW = imread([imageDIR oFileHW]);

oFileLW = '20210226_1203.jpg';
oFileNlw = char(oFileLW);oFileNlw = oFileNlw(1:end-4);
orthoLW = imread([imageDIR oFileLW]);

im1 = orthoHW;
im2 = orthoLW;

imgSize = size(im1);
imgSize = imgSize(1:2);

%analyzeNetwork(net);

features1 = activations(net,im1,'conv3_1'); % pool1>res2b_branch2b
features2 = activations(net,im2,'conv3_1'); 

features11 = reshape(features1,[750000,64]);
features22 = reshape(features2,[750000,64]);

% features11 = reshape(features1,[94000,64]);
% features22 = reshape(features2,[94000,64]);

rowDist = ones(1,75)*10000;
features111 =mat2cell(features11,rowDist);
features222 =mat2cell(features22,rowDist);

for i =1:75
    indexPairs{i} = matchFeatures(features111{i}, features222{i});
    indexPairs{i} = indexPairs{i} + (i-1)*10000;
    if i>1
        indexpairs = cat(1,indexPairs{i-1},indexPairs{i});
    end
end

locations1 = indexpairs(:,1);
locations2 = indexpairs(:,2);

points1 = zeros(size(indexpairs,1),2); 
points2 = zeros(size(indexpairs,1),2);

for i =1:size(indexpairs,1)
    x1 = mod(locations1(i),1000);
    y1 = (locations1(i)-x1)/1000; 
    if x1 == 0
        points1(i,1) = x1 + 1;
    else
        points1(i,1) = x1;
    end
    if y1 == 0
        points1(i,2) = y1 + 1;
    else
        points1(i,2) = y1;
    end
    x2 = mod(locations2(i),1000);
    y2 = (locations2(i)-x2)/1000;
    if x2 == 0
        points2(i,1) = x2 + 1;
    else
        points2(i,1) = x2;
    end
    if y2 == 0
        points2(i,2) = y2 + 1;
    else
        points2(i,2) = y2;
    end
end

points1 = points1.*2;
points2 = points2.*2;
id1 = find(points1(:,1)<20 | points1(:,1)>1980 | points1(:,2)<20 | points1(:,2)>1480);
id2 = find(points2(:,1)<20 | points2(:,1)>1980 | points2(:,2)<20 | points2(:,2)>1480);

id = union(id1,id2);

points1(id,:)=[];
points2(id,:)=[];

[tform, inlierIdx] = ...
    estimateGeometricTransform2D(points1, points2, ...
    'projective','MaxNumTrials',30000,'Confidence',75);
inlierPoints1 = points1(inlierIdx, :);
inlierPoints2 = points2(inlierIdx, :);

figure,showMatchedFeatures(im1,im2,inlierPoints1,inlierPoints2,'blend');
outputView = imref2d(size(im1));

rI2 = imwarp(im2,tform,'OutputView',outputView);

figure, imshowpair(im1,rI2,'blend')

%% 56×56×64×1

% pool1上下
% res2a_branch2a, upper part;res2a_branch2b, deviation;
% res2b_branch2a, upper part;res2b_branch2b, matching not enough
features1 = activations(net,im1,'res3a_branch2a'); % pool1>res2b_branch2b
features2 = activations(net,im2,'res3a_branch2a'); 

features11 = reshape(features1,[187500,64]); % 3136 = 56^2
features22 = reshape(features2,[187500,64]); % size(1,:)*size(:,1)

rowDist = [10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,7500];
features111 =mat2cell(features11,rowDist);
features222 =mat2cell(features22,rowDist);

for i =1:19
    indexPairs{i} = matchFeatures(features111{i}, features222{i});
end

indexPairs{2} = indexPairs{2} + 10000;
indexPairs{3} = indexPairs{3} + 20000;
indexPairs{4} = indexPairs{4} + 30000;
indexPairs{5} = indexPairs{5} + 40000;
indexPairs{6} = indexPairs{6} + 50000;
indexPairs{7} = indexPairs{7} + 60000;
indexPairs{8} = indexPairs{8} + 70000;
indexPairs{9} = indexPairs{9} + 80000;
indexPairs{10} = indexPairs{10} + 90000;
indexPairs{11} = indexPairs{11} + 100000;
indexPairs{12} = indexPairs{12} + 110000;
indexPairs{13} = indexPairs{13} + 120000;
indexPairs{14} = indexPairs{14} + 130000;
indexPairs{15} = indexPairs{15} + 140000;
indexPairs{16} = indexPairs{16} + 150000;
indexPairs{17} = indexPairs{17} + 160000;
indexPairs{18} = indexPairs{18} + 170000;
indexPairs{19} = indexPairs{19} + 180000;

indexPairs = cat(1,indexPairs{1},indexPairs{2},indexPairs{3}, ...
    indexPairs{4},indexPairs{5},indexPairs{6},indexPairs{7}, ...
    indexPairs{8},indexPairs{9},indexPairs{10},indexPairs{11}, ...
    indexPairs{12},indexPairs{13},indexPairs{14},indexPairs{15}, ...
    indexPairs{16},indexPairs{17},indexPairs{18},indexPairs{19});

locations1 = indexPairs(:,1);
locations2 = indexPairs(:,2);

points1 = zeros(895,2); 
points2 = zeros(895,2);

for i =1:895
    x1 = mod(locations1(i),500);
    y1 = (locations1(i)-x1)/500; % Both should be divided by the image width
    if x1 == 0
        points1(i,1) = x1 + 1;
    else
        points1(i,1) = x1;
    end
    if y1 == 0
        points1(i,2) = y1 + 1;
    else
        points1(i,2) = y1;
    end
    x2 = mod(locations2(i),500);
    y2 = (locations2(i)-x2)/500;
    if x2 == 0
        points2(i,1) = x2 + 1;
    else
        points2(i,1) = x2;
    end
    if y2 == 0
        points2(i,2) = y2 + 1;
    else
        points2(i,2) = y2;
    end
end

% id1 = find(points1(:,1)<10 | points1(:,1)>490 | points1(:,2)<10 | points1(:,2)>365);
% id2 = find(points2(:,1)<10 | points2(:,1)>490 | points2(:,2)<10 | points2(:,2)>365);

points1 = points1.*4;
points2 = points2.*4;
id1 = find(points1(:,1)<20 | points1(:,1)>1980 | points1(:,2)<20 | points1(:,2)>1480);
id2 = find(points2(:,1)<20 | points2(:,1)>1980 | points2(:,2)<20 | points2(:,2)>1480);

id = union(id1,id2);

points1(id,:)=[];
points2(id,:)=[];

% figure,showMatchedFeatures(im1,im2,points1,points2,'montage')

%% Merge all points


[tform, inlierIdx] = ...
    estimateGeometricTransform2D(points1, points2, ...
    'affine','MaxNumTrials',30000,'Confidence',75);
inlierPoints1 = points1(inlierIdx, :);
inlierPoints2 = points2(inlierIdx, :);

% im1 = imresize(im1,[375 500]);
% im2 = imresize(im2,[375 500]);

figure,showMatchedFeatures(im1,im2,inlierPoints1,inlierPoints2,'blend');
outputView = imref2d(size(im1));

rI2 = imwarp(im2,tform,'OutputView',outputView);
% imshow(rI2);

% crI2 = imcrop(rI2,[0 ceil(gap/2) size(I2gray,2) ...
%     size(I2gray,1)-gap]);
% cI1 = imcrop(I1,[0 ceil(gap/2) size(rI2,2) ...
%     size(rI2,1)-gap]);
% 
% figure, imshowpair(cI1,crI2,'blend')

figure, imshowpair(im1,rI2,'blend')
