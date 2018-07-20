clear all
clc
close all
addpath(genpath('../../Output/Part3/'));
% %% Color contour.
% % Open video writer, prepare for recording.
% vid = VideoWriter('contour001-100', 'MPEG-4');
% vid.FrameRate = 10;
% open(vid);
% images.filename = ls('../../Output/Part3/out_*.jpg');
% numImages = size(images.filename, 1); 
% for i = 1 : numImages
%     frame = imread(images.filename(i, :));
%     figure ('visible', 'off')
%     imshow(frame);
%     % Record video
%     frameVid = getframe(gcf);
%     writeVideo(vid, frameVid); 
% end
% close(vid)

%% 
% Open video writer, prepare for recording.
vid = VideoWriter('binary001-100', 'MPEG-4');
vid.FrameRate = 10;
open(vid);
images.filename = ls('../../Output/Part3/binary_*.jpg');
numImages = size(images.filename, 1); 
for i = 1 : numImages
    frame = imread(images.filename(i, :));
    figure ('visible', 'off')
    imshow(frame);
    % Record video
    frameVid = getframe(gcf);
    writeVideo(vid, frameVid); 
end
close(vid)