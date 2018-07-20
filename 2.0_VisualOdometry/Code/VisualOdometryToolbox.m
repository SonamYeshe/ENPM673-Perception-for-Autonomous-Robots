clear all
clc
close all
% Generate a subpath for the 2 given codes.
addpath(genpath('./../input/Oxford_dataset/'));
% Extract camera parameters.
[fx, fy, cx, cy, G_camera_image, LUT] = ReadCameraModel('./../input/Oxford_dataset/stereo/centre','./../input/Oxford_dataset/model');
K = [fx 0 cx; 0 fy cy; 0 0 1];
% camPos = [0; 0; 0];
pos = [0 0 0];
Rpos = [1 0 0; 0 1 0; 0 0 1];
% Define camera parameters of the camera.
cameraParams = cameraParameters('IntrinsicMatrix',K');
% Open video writer, prepare for recording.
vid = VideoWriter('Visual Odometry', 'MPEG-4');
vid.FrameRate = 30;
open(vid);
% Extract images dataset.
images.filename = ls('./../input/Oxford_dataset/stereo/centre/*.png');
numImages = size(images.filename, 1); 
for i = 200:(numImages - 1)
    i % Showing what is the step under processing now.
    % Recover to the color images and undistort them.
    I = imread(images.filename(i, :));
    J = demosaic(I, 'GBRG');
    undistortedFrame = UndistortImage(J, LUT);
    INext = imread(images.filename(i + 1, :));
    JNext = demosaic(INext, 'GBRG');
    undistortedFrameNext = UndistortImage(JNext, LUT);
    % Denoise image.
    denoisedUndistortedFrame = imgaussfilt(undistortedFrame, 0.8);
    denoisedUndistortedFrameNext = imgaussfilt(undistortedFrameNext, 0.8);
    % Convert to grayscale.
    grayscaleUndistortedFrame = rgb2gray(denoisedUndistortedFrame);
    grayscaleUndistortedFrameNext = rgb2gray(denoisedUndistortedFrameNext);
    % Imitate Mathworks tutorial: Object Detection in a Cluttered Scene Using Point Feature Matching.
    % Detect feature points.
    framePoints = detectSURFFeatures(grayscaleUndistortedFrame);
    frameNextPoints = detectSURFFeatures(grayscaleUndistortedFrameNext);
    % Extract feature descriptors.
    [frameFeatures, framePoints] = extractFeatures(grayscaleUndistortedFrame, framePoints);
    [frameNextFeatures, frameNextPoints] = extractFeatures(grayscaleUndistortedFrameNext, frameNextPoints);
    % Find putative point matches.
    framePairs = matchFeatures(frameFeatures, frameNextFeatures);
    matchedFramePoints = framePoints(framePairs(:, 1), :);
    matchedFrameNextPoints = frameNextPoints(framePairs(:, 2), :);
    % Using computer vision system toolbox to calculate F matrix and inliers.
    [F, inliersIndex] = estimateFundamentalMatrix(matchedFramePoints, matchedFrameNextPoints);
    % Update selected points with only inliers.
    inlierPoints1 = matchedFramePoints(inliersIndex,:);
    inlierPoints2 = matchedFrameNextPoints(inliersIndex,:);
    [relativeOrientation, relativeLocation] = relativeCameraPose(F, cameraParams, inlierPoints1, inlierPoints2);
    % Calculate the position and orientation of the camera.
    relativeLocation = -relativeLocation * relativeOrientation;
    Rpos = relativeOrientation * Rpos;
    pos = pos + relativeLocation * Rpos;
    % Plot the trajectory.
    figure(1)
    subplot(1, 2, 1)
    imshow(J)
    title('Camera Feed')
    subplot(1, 2, 2)
    title('Trajectory')
    plot(-pos(1), -pos(3), 'ro')
    % Important: Let the x, y axis plot have the same scale.
    axis equal
    hold on
    % Record video.
    frame = getframe(gcf);
    writeVideo(vid, frame); 
    pause(0.001)
end
close(vid)