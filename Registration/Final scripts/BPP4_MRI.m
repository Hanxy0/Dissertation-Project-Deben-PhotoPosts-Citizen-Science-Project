% ---
clear all; clc;

% choice of feature mapping?
ext = 'suaf.tif';

% load BPP4step1.mat

imageDIR = ['C:/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Images/Post4/'];
oFileHW = '20210119.jpg';
oFileNhw = char(oFileHW);oFileNhw = oFileNhw(1:end-4);
orthoHW = imread([imageDIR oFileHW]);

oFileLW = '20210407.jpg';
oFileNlw = char(oFileLW);oFileNlw = oFileNlw(1:end-4);
orthoLW = imread([imageDIR oFileLW]);

% Rough registration
[optimizer, metric] = imregconfig('multimodal'); % multimodal
 
% movingRegisteredDefault = imregister(moving, fixed, 'affine', optimizer, metric);
% movingRegisteredDefault = imregister(rgb2gray(orthoLW), rgb2gray(orthoHW), ...
%     'rigid', optimizer, metric);
%figure, imshowpair(movingRegisteredDefault, fixed);
%title('Default registration');

% Display the default generated optimizer and metric function parameters
% disp(optimizer);
% disp(metric);

% Adjust the parameters
optimizer.InitialRadius = optimizer.InitialRadius / 5;
optimizer.MaximumIterations = 300;
 
% Transformation matrix tformSimilarity.T
tformSimilarity = imregtform(rgb2gray(orthoLW), rgb2gray(orthoHW), ...
    'rigid', optimizer, metric);
 
% Change initial conditions to improve accuracy
Rfixed = imref2d(size(orthoHW));

% Precise registration
movingRegisteredRigid = imwarp(rgb2gray(orthoLW), tformSimilarity, ...
    'OutputView', Rfixed);
figure;imshowpair(movingRegisteredRigid, orthoHW);

mi=MI(movingRegisteredRigid, orthoHW);

save BPP4step1.mat

load BPP4step1.mat

C = imfuse(movingRegisteredRigid, orthoHW);

resultsDIR = ['C:/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Results/BPP4_surfaffi_MRI/'];

imwrite(orthoHW,[resultsDIR oFileNhw ext],'TIFF')

filelist = dir(fullfile(imageDIR,'*.jpg'));
%idOK = find([filelist.bytes]'>50000);
listNames = {filelist.name}';
%listNames = fileNames(idOK);
%listNames = setdiff(listNames,oFileHW);

alreadyProcessed = dir(fullfile(resultsDIR,['*' ext]));
alreadyNames = {alreadyProcessed.name}';

tic;

for i = 1:length(listNames)
    iFile = listNames{i};
    iFileN = char(iFile);iFileN = iFileN(1:end-4);
    if ismember([iFileN ext],alreadyNames)
    else
%         siftproj(iFile,orthoHW,imageDIR,resultsDIR)
        surfproj(iFile,C,imageDIR,resultsDIR)
%         surfsimi(iFile,cO,imageDIR,resultsDIR)
%         siftproj(iFile,cO,imageDIR,resultsDIR)
%         siftsimi(iFile,cO,imageDIR,resultsDIR)
    end
    clearvars -except imageDIR resultsDIR C listNames i oFile alreadyNames ext tic
end

toc;

I1 = imread('C:/Users/Han Xinyu/OneDrive - University College London/Desktop/Dissertation/Results/BPP2_surfprojMRI/20201220_1113supr.tif');
I2 = imread('C:/Users/Han Xinyu/OneDrive - University College London/Desktop/Dissertation/Results/BPP2_surfprojMRI/20220811_1117supr.tif');

figure()
imshowpair(I1,I2,'montage');

I3 = imread('C:/Users/Han Xinyu/OneDrive - University College London/Desktop/Dissertation/Results/BPP3_surfprojMRI/20201230supr.tif');
I4 = imread('C:/Users/Han Xinyu/OneDrive - University College London/Desktop/Dissertation/Results/BPP3_surfprojMRI/20220814_1104supr.tif');

figure()
imshowpair(I3,I4,'montage');

I5 = imread('C:/Users/Han Xinyu/OneDrive - University College London/Desktop/Dissertation/Results/BPP4_surfsimi_MRI/20200811supr.tif');
I6 = imread('C:/Users/Han Xinyu/OneDrive - University College London/Desktop/Dissertation/Results/BPP4_surfsimi_MRI/20220810_1537supr.tif');

figure()
imshowpair(I5,I6,'montage');