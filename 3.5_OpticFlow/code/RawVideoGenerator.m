clear all
clc
close all
% Load images.
addpath('./../dataset/eval-data-gray/Wooden/');
% addpath('./../dataset/eval-data-gray/Grove/');
% Extract images dataset.
images.filename = ls('./../dataset/eval-data-gray/Wooden/*.png');
% images.filename = ls('./../dataset/eval-data-gray/Grove/*.png');
numImages = size(images.filename, 1); 
% Open video writer, prepare for recording.
vid = VideoWriter('Wooden_Raw', 'MPEG-4');
% vid = VideoWriter('Grove_Raw', 'MPEG-4');
vid.FrameRate = 3;
open(vid);
for k = 1 : numImages - 1
    image1 = imread(images.filename(k, :));
    figure(1);
    imshow(image1);
    % Record video
    frame = getframe(gca);
    writeVideo(vid, frame); 
end
close(vid)