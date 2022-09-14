function surfproj(iFile,C,imageDIR,resultsDIR)

ext = 'suaf.tif';
iFileN = char(iFile);iFileN = iFileN(1:end-4); % char:转换为字符数组 为什么去掉后四个？
inImage = imread([imageDIR iFile]); % 输入图像
% [ra,ca] = size(C);
% inImage = imresize(inImage,[ra,ca]);

% adjust the size of images to match
% i.e. buffer with padding where needed
i1 = C;  i2 = inImage;
sc = size(i1,2)/size(i2,2);   % 两幅图宽度的比值
i2b = imresize(i2,sc);        % 将输入图像调整到参考图像一样大

gap = size(i2b,1)-size(i1,1); % 高的差值

if gap<0                      % 输入<参考
    i1b = imcrop(i1,[0 -gap size(i1,2) size(i1,1)+gap]); % 裁剪参考图像

    if size(i1b,1)>size(i2b,1) % 参考 高 仍>输入
        i1b(1,:,:) = [];
    end
else
    i1b = padarray(i1,[ceil(gap/2),0,0]); % ceil是取整为大于或等于最接近该元素的整数
                                          % 差值的一半，对第一维度（高）做填充

    if ceil(gap/2)>(gap/2) % 取整取多了
        i1b(1,:,:) = [];
    end
end

I1=i1b;I2=i2b;
% I1 = C; I2 = inImage;

c=1;
for p=1:3
    for q=1:3
        % convert to grey and increase contrast
        I1gray = I1(:,:,p);
        I1gray = imadjust(I1gray,stretchlim(I1gray),[]);

        I2gray = I2(:,:,q);
        I2gray = imadjust(I2gray,stretchlim(I2gray),[]);

        % detect features
        blobs1 = detectSURFFeatures(I1gray);
        blobs2 = detectSURFFeatures(I2gray);

        % extract feature information
        [features1, validBlobs1] = extractFeatures(I1gray,blobs1);
        [features2, validBlobs2] = extractFeatures(I2gray,blobs2);

        indexPairs = matchFeatures(features1, features2);

        matchedPoints1 = validBlobs1(indexPairs(:,1),:);
        matchedPoints2 = validBlobs2(indexPairs(:,2),:);

        % figure,showMatchedFeatures(I1gray,I2gray,matchedPoints1,matchedPoints2,'montage')

        % remove all points within 20 pixels of the edge
        x1 = matchedPoints1.Location';
        x2 = matchedPoints2.Location';

%         okPts1 = find((x1(1,:)>20 & x1(1,:)<size(I1gray,2)-20) & ...
%             (x1(2,:)>(ceil(gap/2)+20) & ...
%             x1(2,:)<size(I1gray,1)-(ceil(gap/2)+20)));
% 
%         okPts2 = find((x2(1,:)>20 & x2(1,:)<size(I2gray,2)-20) & ...
%             (x2(2,:)>20 & x2(2,:)<size(I2gray,1)-20));
%
%         okPts = intersect(okPts1,okPts2);

%         mPts1{c} = matchedPoints1(okPts);
%         mPts2{c} = matchedPoints2(okPts);
        mPts1{c} = matchedPoints1;
        mPts2{c} = matchedPoints2;
        c=c+1;
    end
end

finalMPts1 = cat(2,mPts1{1},mPts1{2},mPts1{3},...
    mPts1{4},mPts1{5},mPts1{6},...
    mPts1{7},mPts1{8},mPts1{9});
finalMPts2 = cat(2,mPts2{1},mPts2{2},mPts2{3},...
    mPts2{4},mPts2{5},mPts2{6},...
    mPts2{7},mPts2{8},mPts2{9});

% showMatchedFeatures(I1gray,I2gray,finalMPts1,finalMPts2,'montage');

if finalMPts1.Count<5 || finalMPts2.Count<5 || ...
        min(std(finalMPts2.Location))<0.09
    %kazeproj(iFile,cO,imageDIR,resultsDIR)
%     t = fitgeotrans(movingPoints,fixedPoints,'projective'); % 改相应的几何变换！
%     cOfix = imref2d(size(I1));
%     rI2 = imwarp(I2,t,'OutputView',cOfix);
%     crI2 = imcrop(rI2,[0 ceil(gap/2) size(I2gray,2) ...
%         size(I2gray,1)-gap]);
%     kspace = sum(sum(crI2(:,:,1)==0))./(size(crI2,1)*size(crI2,2));
%     if kspace>0.33
%     else
%         imwrite(crI2,[resultsDIR iFileN ext],'TIFF') % 输出配准结果图像
%     end
else
    % calculate transformation 去除野值
    [tform, inlierIdx] = ...
        estimateGeometricTransform2D(finalMPts2, finalMPts1, ...
        'affine','MaxNumTrials',30000,'Confidence',75);
    inlierPoints1 = finalMPts1(inlierIdx, :);
    %inlierPoints2 = finalMPts2(inlierIdx, :);

    % showMatchedFeatures(I1gray,I2gray,inlierPoints1,inlierPoints2,'montage');
    outputView = imref2d(size(I1));

    rI2 = imwarp(I2,tform,'OutputView',outputView);
    crI2 = imcrop(rI2,[0 ceil(gap/2) size(I2gray,2) ...
        size(I2gray,1)-gap]);
    cI1 = imcrop(I1,[0 ceil(gap/2) size(rI2,2) ...
        size(rI2,1)-gap]);

    % figure, imshowpair(cI1,crI2,'montage')
    kspace = sum(sum(crI2(:,:,1)==0))./(size(crI2,1)*size(crI2,2)); % crI2全变为rI2
    if kspace>0.33
    else
        imwrite(crI2,[resultsDIR iFileN ext],'TIFF') % 输出配准结果图像
    end
end