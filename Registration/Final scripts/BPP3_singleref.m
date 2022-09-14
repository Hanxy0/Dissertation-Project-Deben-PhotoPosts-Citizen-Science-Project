% ---

% choice of feature mapping?
% ext = 'sipr9.tif';
% ext = 'sisi9.tif';
ext = '.tif';
% ext = 'sino9.tif';

% ext = 'supr9.tif';
% ext = 'susi9.tif';
% ext = 'suaf9.tif';
% ext = 'suno9.tif';

% ext = 'orpr9.tif';
% ext = 'orsi9.tif';
% ext = 'oraf9.tif';
% ext = 'orno9.tif';

% ext = 'kapr9.tif';
% ext = 'kasi9.tif';
% ext = 'kaaf9.tif';
% ext = 'kano9.tif';


% load BPP4step1.mat

imageDIR = ['/Users/Han Xinyu/OneDrive - University College London/' ...
    'Desktop/Dissertation/Images/Post3_resample34/'];
oFileHW = '20210125_1109.tif';
oFileNhw = char(oFileHW);oFileNhw = oFileNhw(1:end-4);
orthoHW = imread([imageDIR oFileHW]);

% oFileLW = '20210205_1106.jpg';
% oFileNlw = char(oFileLW);oFileNlw = oFileNlw(1:end-4);
% orthoLW = imread([imageDIR oFileLW]);

% load post3_fixed.mat
% load post3_moving.mat
% 
% % [mp,fp] = cpselect(orthoLW,orthoHW,'Wait',true);    
% t = fitgeotrans(movingPoints,fixedPoints,'projective'); % 改相应的几何变换！
% cOfix = imref2d(size(orthoHW));
% rImage = imwarp(orthoLW,t,'OutputView',cOfix);

save BPP3step1.mat

load BPP3step1.mat

resultsDIR = ['/Users/Han Xinyu/OneDrive - University College London/' ...
    'Desktop/Dissertation/Results/BPP3_surfproj_resample34/'];
% cOhw = imcrop(orthoHW,[150 1000 3800 2000]); (150,1000) to (3950, 3000)
% cOlw = imcrop(rImage,[150 1000 3800 2000]);
% 
% cOhw = imresize(cOhw,0.5);
% cOlw = imresize(cOlw,0.5);
% cOhw = imresize(orthoHW,0.5);
% cOlw = imresize(rImage,0.5);
% cO = imfuse(orthoHW,rImage);
% 
% imwrite(cOhw,[resultsDIR oFileNhw ext],'TIFF')
% imwrite(cOlw,[resultsDIR oFileNlw ext],'TIFF')
imwrite(orthoHW,[resultsDIR oFileNhw ext],'TIFF')

filelist = dir(fullfile(imageDIR,'*.tif'));
% idOK = find([filelist.bytes]'>50000);
% fileNames = {filelist.name}';
% listNames = fileNames(idOK);
% listNames = setdiff(setdiff(listNames,oFileHW),oFileLW);
listNames = {filelist.name};
listNames = setdiff(listNames,oFileHW);

alreadyProcessed = dir(fullfile(resultsDIR,['*' ext]));
% alreadyProcessed = dir(fullfile(resultsDIR,'*sisi9.tif'));
alreadyNames = {alreadyProcessed.name}';

for i = 1:length(listNames)
    iFile = listNames{i};
    iFileN = char(iFile);iFileN = iFileN(1:end-4);
    if ismember([iFileN ext],alreadyNames)
    else
        siftproj(iFile,orthoHW,imageDIR,resultsDIR)
    %     surfproj(iFile,cO,imageDIR,resultsDIR)
    %     surfsimi(iFile,cO,imageDIR,resultsDIR)
    %     siftproj(iFile,cO,imageDIR,resultsDIR)
    %     siftsimi(iFile,cO,imageDIR,resultsDIR)
    end
    clearvars -except imageDIR resultsDIR orthoHW listNames i iFile alreadyNames ext
end