clc;
clear all;
close all;
%% Extract all the frames from a video, for the future image proces
v = VideoReader('./../../detectbuoy.avi');
numberOfFrames = v.NumberOfFrames;
for i = 1 : 9
    %% Extract frames to TrainingSet/Frames/
    rgbImage = read(v, i);
    imwrite(rgbImage, ['./../../Images/TrainingSet/Frames/00' int2str(i), '.jpg']);

%     %% Extract frames to TestSet/Frames/
%     rgbImage = read(v, i);
%     imwrite(rgbImage, ['./../../Images/TestSet/Frames/00' int2str(i), '.jpg']);
end
for i = 10 : 99
    %% Extract frames to TrainingSet/Frames/
    rgbImage = read(v, i);
    imwrite(rgbImage, ['./../../Images/TrainingSet/Frames/0' int2str(i), '.jpg']);

%     %% Extract frames to TestSet/Frames/
%     rgbImage = read(v, i);
%     imwrite(rgbImage, ['./../../Images/TestSet/Frames/0' int2str(i), '.jpg']);
end
for i = 100 : numberOfFrames
    %% Extract frames to TrainingSet/Frames/
    rgbImage = read(v, i);
    imwrite(rgbImage, ['./../../Images/TrainingSet/Frames/' int2str(i), '.jpg']);

%     %% Extract frames to TestSet/Frames/
%     rgbImage = read(v, i);
%     imwrite(rgbImage, ['./../../Images/TestSet/Frames/' int2str(i), '.jpg']);
end