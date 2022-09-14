% The function of this script is to pre-process(resize) 
% the image dataset and generate video as frames

% resize images
addpath(['/Users/Han Xinyu/OneDrive - University College London/' ...
    'Desktop/Dissertation/Results/BPP4_surfsimi_MRI_f_resize/']); % Storage location 
addpath(['/Users/Han Xinyu/OneDrive - University College London/' ...
    'Desktop/Dissertation/Results/BPP4_surfsimi_MRI_f/']); % Original image folder
ListName=dir(['/Users/Han Xinyu/OneDrive - University College London/' ...
    'Desktop/Dissertation/Results/BPP4_surfsimi_MRI_f/*.tif']); % Format of images
[m,n]=size(ListName);    
for i=1:m % Loop through all images in a folder      
    origImg=imread(ListName(i).name);    % readImg    
    Img=imresize(origImg,[1512 2016]);   % resize the images as 1500*1000
    dstName=ListName(i).name;    
    dstAddress=['/Users/Han Xinyu/OneDrive - University College London/' ...
        'Desktop/Dissertation/Results/BPP4_surfsimi_MRI_f_resize/'];    
    All=strcat(dstAddress,dstName);    
    AllImg=imresize(Img,1);    
    imwrite(AllImg,All);    
end

% Add the corresponding shooting date to each frame
imageDIR = ['C:/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Results/BPP4_surfsimi_MRI_f_resize/'];

resultsDIR = ['C:/Users/Han Xinyu/OneDrive - University College London' ...
    '/Desktop/Dissertation/Results/BPP4_surfsimi_MRI_f_videoframe/'];

ext = '.tif';

filelist = dir(fullfile(imageDIR,'*.tif'));
listNames = {filelist.name}';

alreadyProcessed = dir(fullfile(resultsDIR,['*' ext]));
alreadyNames = {alreadyProcessed.name}';

for i = 1:length(listNames)
    iFile = listNames{i};
    iFileN = char(iFile);iFileN = iFileN(1:end-4);
    if ismember([iFileN ext],alreadyNames)
    else
        adddate(iFile, imageDIR, resultsDIR)
    end
    clearvars -except imageDIR resultsDIR listNames alreadyNames i iFile ext
end


% Convert pics to video
pic2video(['/Users/Han Xinyu/OneDrive - University College London/' ...
    'Desktop/Dissertation/Results/BPP4_surfsimi_MRI_f_videoframe/'],'tif', ...
    'BPP4.avi',['/Users/Han Xinyu/OneDrive - University College London/' ...
    'Desktop/Dissertation/Results/BPP4_surfsimi_MRI_f_videoframe/'])

%%
function pic2video(dn, picformat,aviname,avipath)

% dn : Folders for storing images
% picformat : The format of the image to be read
% aviname   : The file name of the stored video

    if ~exist(dn, 'dir')
        error('dir not exist!!!!');
    end
    picname=fullfile( dn, strcat('*.',picformat));
    picname=dir(picname);

    frame_rate = 2; % Video frame rate
  
    aviobj = VideoWriter(strcat(avipath,aviname)); % Initializing an avi file
    aviobj.FrameRate = frame_rate; % Setting the frame rate

    open(aviobj);

    for i=1:length(picname)
        picdata=imread( fullfile(dn, (picname(i,1).name)));
        if ~isempty( aviobj.Height)
            if size(picdata,1) ~= aviobj.Height || size(picdata,2) ~= aviobj.Width
                close(aviobj);
                delete( aviname )
                error('Warning: All images should be the same size！！!');
            end
        end
        writeVideo(aviobj,picdata);
    end
    close(aviobj);
end


function adddate(iFile, imageDIR, resultsDIR)

ext = '.tif';
iFileN = char(iFile);iFileN = iFileN(1:8);
img = imread([imageDIR iFile]);

yr = iFileN(1:4);
mon = iFileN(5:6);
dy = iFileN(7:8);

str = [yr,'-',mon,'-',dy];
newstr = join(str);

imshow(img);
text(500,550,newstr,'horiz','center','color','k','FontSize',20);

f=getframe(figure(1));

imwrite(f.cdata,[resultsDIR iFileN ext],'TIFF')

end
