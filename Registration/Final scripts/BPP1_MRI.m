% This script is developed on the basis of work 
% done previously by Prof Burningham Helene

% ---
clear all; clc;

% choice of feature mapping?
ext = 'supr.tif';

% load BPP4step1.mat

imageDIR = ['C:/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Images/Post1/'];
oFileHW = '20210427_1054.jpg';
oFileNhw = char(oFileHW);oFileNhw = oFileNhw(1:end-4);
orthoHW = imread([imageDIR oFileHW]);

oFileLW = '20210518_0937.jpg';
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

save BPP1step1.mat

load BPP1step1.mat

C = imfuse(movingRegisteredRigid, orthoHW);

resultsDIR = ['C:/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Results/BPP1_surfprojMRI/'];

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