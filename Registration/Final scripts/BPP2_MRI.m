% ---
%clear all; clc;

% choice of feature mapping?
ext = 'SIHa.tif';

% load BPP4step1.mat

imageDIR = ['C:/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Images/Post2_filtered/'];
oFileHW = '20210122_1100.jpg';
oFileNhw = char(oFileHW);oFileNhw = oFileNhw(1:end-4);
orthoHW = imread([imageDIR oFileHW]);

oFileLW = '20201229_1200.jpg';
oFileNlw = char(oFileLW);oFileNlw = oFileNlw(1:end-4);
orthoLW = imread([imageDIR oFileLW]);

% Rough registration
[optimizer, metric] = imregconfig('multimodal'); % multimodal
 
% movingRegisteredDefault = imregister(moving, fixed, 'affine', optimizer, metric);
movingRegisteredDefault = imregister(rgb2gray(orthoLW), rgb2gray(orthoHW), ...
    'similarity', optimizer, metric);
%figure, imshowpair(movingRegisteredDefault, fixed);
%title('Default registration');

% Display the default generated optimizer and metric function parameters
disp(optimizer);
disp(metric);

% Adjust the parameters
optimizer.InitialRadius = optimizer.InitialRadius / 5;
optimizer.MaximumIterations = 500;
 
% Transformation matrix tformSimilarity.T
tformSimilarity = imregtform(rgb2gray(orthoLW), rgb2gray(orthoHW), ...
    'rigid', optimizer, metric);
 
% Change initial conditions to improve accuracy
Rfixed = imref2d(size(orthoHW));

% Precise registration
movingRegisteredRigid = imwarp(orthoLW, tformSimilarity, ...
    'OutputView', Rfixed);
% figure;imshowpair(movingRegisteredRigid, orthoHW);

% mi=MI(movingRegisteredRigid, orthoHW);

C = imfuse(movingRegisteredRigid, orthoHW);

save BPP2step1.mat
load BPP2step1.mat

resultsDIR = ['C:/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Results/BPP2_SIFTHarris/'];

imwrite(orthoHW,[resultsDIR oFileNhw ext],'TIFF')

filelist = dir(fullfile(imageDIR,'*.jpg'));
%idOK = find([filelist.bytes]'>50000);
listNames = {filelist.name}';
%listNames = fileNames(idOK);
%listNames = setdiff(listNames,oFileHW);

alreadyProcessed = dir(fullfile(resultsDIR,['*' ext]));
alreadyNames = {alreadyProcessed.name}';

%%
for i = 1:length(listNames)
    iFile = listNames{i};
    iFileN = char(iFile);iFileN = iFileN(1:end-4);
    if ismember([iFileN ext],alreadyNames)
    else
        SIFTHarrisproj(C,iFile,imageDIR,resultsDIR)
    end
    clearvars -except imageDIR resultsDIR listNames alreadyNames C i iFile ext
end
