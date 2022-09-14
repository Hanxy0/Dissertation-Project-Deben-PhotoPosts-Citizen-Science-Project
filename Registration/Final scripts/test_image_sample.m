% ---

gpuDevice(1);

% 2 reference images
imageDIR = ['/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Images/Post3/'];
oFileHW = '20210125_1109.jpg'; % 20210122_1100
oFileNhw = char(oFileHW);oFileNhw = oFileNhw(1:end-4);
orthoHW = imread([imageDIR oFileHW]);

oFileLW = '20210205_1106.jpg'; % 20210301_1304
oFileNlw = char(oFileLW);oFileNlw = oFileNlw(1:end-4);
orthoLW = imread([imageDIR oFileLW]);
%orthoLW = imresize(orthoLW,[1162,2065]);

orthoHW = im2gray(orthoHW);
orthoLW = im2gray(orthoLW);

c1 = normxcorr2(orthoHW,orthoLW);
surf(c1)
shading flat

[ypeak,xpeak] = find(c1==max(c1(:)));

yoffSet = ypeak-size(orthoLW,1);
xoffSet = xpeak-size(orthoLW,2);

imshow(orthoHW)
drawrectangle(gca,'Position',[xoffSet,yoffSet,size(orthoLW,2), ...
    size(orthoLW,1)],'FaceAlpha',0);

%save detectstep1.mat
%load detectstep1.mat

resultsDIR = ['/Users/Han Xinyu/OneDrive - University College London/' ...
    'Desktop/Dissertation/Results/Algorithms_comparison_P1_simi/'];


tic;

% adjust the size of images to match
% i.e. buffer with padding where needed
i1 = orthoHW; i2 = orthoLW;
sc = size(i1,2)/size(i2,2);   % Ratio of the width of the two images
i2b = imresize(i2,sc);        % Resize the input image to the same size as the reference image

gap = size(i2b,1)-size(i1,1); % Difference of height

if gap<0                      % Input<reference
    i1b = imcrop(i1,[0 -gap size(i1,2) size(i1,1)+gap]); % crop reference image

    if size(i1b,1)>size(i2b,1) % Reference Height Still > Input
        i1b(1,:,:) = [];
    end
else
    i1b = padarray(i1,[ceil(gap/2),0,0]); 
    % ceil is rounded to an integer greater than or equal to the nearest element
    % Half of the difference, padding the first dimension (high)

    if ceil(gap/2)>(gap/2) 
        i1b(1,:,:) = [];
    end
end
I1=i1b;I2=i2b;

Noblobs1 = 0;
Noblobs2 = 0;

NomatchedPoints1 = 0;


c=1;
for p=1:3
    for q=1:3
        % convert to grey and increase contrast
        I1gray = I1(:,:,p);
        I1gray = imadjust(I1gray,stretchlim(I1gray),[]);

        I2gray = I2(:,:,q);
        I2gray = imadjust(I2gray,stretchlim(I2gray),[]);

        % detect features
        blobs1 = detectFASTFeatures(I1gray); % KAZE
        %blobs1 = blobs1.selectStrongest(40000);
        blobs2 = detectFASTFeatures(I2gray);
        %blobs2 = blobs2.selectStrongest(40000);

        Noblobs1 = blobs1.Count + Noblobs1;
        Noblobs2 = blobs2.Count + Noblobs2;

        % extract feature information 
        % from Mathworks official guide
        [features1, validBlobs1] = extractFeatures(I1gray,blobs1);
        [features2, validBlobs2] = extractFeatures(I2gray,blobs2);

        indexPairs1 = matchFeatures(features1, features2); 
        
        matchedPoints1 = validBlobs1(indexPairs1(:,1),:);
        matchedPoints2 = validBlobs2(indexPairs1(:,2),:);

        NomatchedPoints1 = matchedPoints1.Count + NomatchedPoints1;
        % figure,showMatchedFeatures(I1gray,I2gray,matchedPoints1,matchedPoints2,'montage')

        % remove all points within 20 pixels of the edge
        x1 = matchedPoints1.Location';
        x2 = matchedPoints2.Location';

        okPts1 = find((x1(1,:)>20 & x1(1,:)<size(I1gray,2)-20) & ...
            (x1(2,:)>(ceil(gap/2)+20) & ...
            x1(2,:)<size(I1gray,1)-(ceil(gap/2)+20)));

        okPts2 = find((x2(1,:)>20 & x2(1,:)<size(I2gray,2)-20) & ...
            (x2(2,:)>20 & x2(2,:)<size(I2gray,1)-20));

        okPts = intersect(okPts1,okPts2);

        mPts1{c} = matchedPoints1(okPts);
        mPts2{c} = matchedPoints2(okPts);

        c=c+1;
    end
end

Noblobs1;
Noblobs2;
NomatchedPoints1;

finalMPts1 = cat(2,mPts1{1},mPts1{2},mPts1{3},...
    mPts1{4},mPts1{5},mPts1{6},...
    mPts1{7},mPts1{8},mPts1{9});
finalMPts2 = cat(2,mPts2{1},mPts2{2},mPts2{3},...
    mPts2{4},mPts2{5},mPts2{6},...
    mPts2{7},mPts2{8},mPts2{9});

figure; ax1 = axes;
showMatchedFeatures(orthoHW,orthoLW,finalMPts1,finalMPts2, ...
    'montage','Parent',ax1,'PlotOptions',{'ro','go','y-'});
legend(ax1,'Matched points (Fixed Image)','Matched points (Moving Image)');
m1 = gca;
exportgraphics(m1,[resultsDIR 'P1FASTrigid_initialmatch.jpg'],'Resolution',300)

% showMatchedFeatures(I1gray,I2gray,finalMPts1,finalMPts2,'montage');


if finalMPts1.Count<5 || finalMPts2.Count<5
else
    % calculate transformation
    [tform, inlierIdx] = ...
        estimateGeometricTransform2D(finalMPts1, finalMPts2, ...
        'rigid','MaxNumTrials',30000,'Confidence',75);
    inlierPoints1 = finalMPts1(inlierIdx, :);
    inlierPoints2 = finalMPts2(inlierIdx, :);
    
    figure; ax2 = axes;
    showMatchedFeatures(orthoHW,orthoLW,inlierPoints1,inlierPoints2, ...
        'montage','Parent',ax2,'PlotOptions',{'ro','go','y-'});
    legend(ax2,'Matched points (Fixed Image)','Matched points (Moving Image)');
    m2 = gca;
    exportgraphics(m2,[resultsDIR 'P1FASTrigid_finalmatch.jpg'],'Resolution',300)

    outputView = imref2d(size(I1));

    rI2 = imwarp(I2,tform,'OutputView',outputView);
    crI2 = imcrop(rI2,[0 ceil(gap/2) size(I2gray,2) ...
        size(I2gray,1)-gap]);
    cI1 = imcrop(I1,[0 ceil(gap/2) size(rI2,2) ...
        size(rI2,1)-gap]);

    figure, imshowpair(cI1,crI2,'blend')
    r = gca;
    exportgraphics(r,[resultsDIR 'P1FASTrigid_resultmontage.jpg'],'Resolution',300)

    %kspace = sum(sum(crI2(:,:,1)==0))./(size(crI2,1)*size(crI2,2));
    % size(crI2) = (1500, 2000, 3)

end

toc;

mse = immse(crI2,cI1);
mi = MI(crI2,cI1);
% R = corrcoef(X,Y);
peaksnr = psnr(crI2,cI1);
% snrval = snr(crI2,cI1);
ssimval = ssim(crI2,cI1);

