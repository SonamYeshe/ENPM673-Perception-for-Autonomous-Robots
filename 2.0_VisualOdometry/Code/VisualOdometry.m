clear all
clc
close all
% Generate a subpath for the 2 given codes.
addpath(genpath('./../input/Oxford_dataset/'));
% Extract camera parameters.
[fx, fy, cx, cy, G_camera_image, LUT] = ReadCameraModel('./../input/Oxford_dataset/stereo/centre','./../input/Oxford_dataset/model');
K = [fx 0 cx; 0 fy cy; 0 0 1];
pos = [0 0 0];
Rpos = [1 0 0; 0 1 0; 0 0 1];
% Open video writer, prepare for recording.
vid = VideoWriter('Visual Odometry', 'MPEG-4');
vid.FrameRate = 30;
open(vid);
% Extract images dataset.
images.filename = ls('./../input/Oxford_dataset/stereo/centre/*.png');
numImages = size(images.filename, 1); 
for i = 200 : (numImages - 1)
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
    framePairs = matchFeatures(frameFeatures, frameNextFeatures, 'MaxRatio', 0.2);
    matchedFramePoints = framePoints(framePairs(:, 1), :);
    matchedFrameNextPoints = frameNextPoints(framePairs(:, 2), :);
    % Using RANSAC algorithm to eliminate outliers.
    pointsSelected = zeros(2, size(matchedFrameNextPoints, 1));
    pointsNextSelected = zeros(2, size(matchedFrameNextPoints, 1));
    pointsSelected(1, :) = matchedFramePoints.Location(:, 1);
    pointsSelected(2, :) = matchedFramePoints.Location(:, 2);
    pointsNextSelected(1, :) = matchedFrameNextPoints.Location(:, 1);
    pointsNextSelected(2, :) = matchedFrameNextPoints.Location(:, 2);
    [~, inliers] = ransacfitfundmatrix(pointsSelected, pointsNextSelected, 0.001);
    % Update selected points with only inliers. And cart2hom().
    pointsSelectedInliers = zeros(3,size(inliers, 2));
    pointsNextSelectedInliers = zeros(3,size(inliers, 2));
    pointsSelectedInliers(1, :) = pointsSelected(1, inliers);
    pointsSelectedInliers(2, :) = pointsSelected(2, inliers);
    pointsSelectedInliers(3, :) = ones(1, size(inliers, 2));
    pointsNextSelectedInliers(1, :) = pointsNextSelected(1, inliers);
    pointsNextSelectedInliers(2, :) = pointsNextSelected(2, inliers);
    pointsNextSelectedInliers(3, :) = ones(1, size(inliers, 2));
    % Normalize the images.
    [normalizedPointsSelected, T1] = normalise2dpts(pointsSelectedInliers);
    [normalizedPointsNextSelected, T2] = normalise2dpts(pointsNextSelectedInliers);
    % Follow youtube video: Lecture 13: Fundamental Matrix. to build matrix A.
    A = [normalizedPointsNextSelected(1, :)'.*normalizedPointsSelected(1, :)'  ...
         normalizedPointsNextSelected(1, :)'.*normalizedPointsSelected(2, :)'  ...
         normalizedPointsNextSelected(1, :)'  ...
         normalizedPointsNextSelected(2, :)'.*normalizedPointsSelected(1, :)'  ...
         normalizedPointsNextSelected(2, :)'.*normalizedPointsSelected(2, :)'  ...
         normalizedPointsNextSelected(2, :)'  normalizedPointsSelected(1, :)'  ...
         normalizedPointsSelected(2, :)'  ...
         ones(size(inliers,2), 1)];  
    % Determine the eigenvector corresponding to the smallest eigenvalue of A. To construct F.
    [U, S, V] = svd(A, 0);
    F = reshape(V(:, 9), [3 3])';
    % Constraint enforcement SVD decomposition.
    [UF, SF, VF] = svd(F, 0);
    F = UF * diag([SF(1, 1) SF(2, 2) 0]) * VF';
    % Denormalise.
    F = T2' * F * T1;
    % Normalise F.
    F = F / norm(F);
    F(3, 3) = abs(F(3, 3));
    % Calculate the essential matrix.
    E = K' * F * K;
    % Extraction of cameras from the essential matrix: 
    % Follow instrucyion from book: Multiple View Geometry in Computer Vision (Second Edition)
    % Chapter 9.6
    W = [0 -1 0; 1 0 0; 0 0 1];
    Z = [0 1 0; -1 0 0; 0 0 0];
    [UE, SE, VE] = svd(E);
    E = UE * Z * W * VE';
    [UE, ~, VE] = svd(E);
    % Calculate 4 possible choices of camera matrix PNext.
    u3 = UE(:, 3);
    R1 = UE * W * VE';
    R2 = UE * W' * VE';
    % Right-handed helix.
    if det(R1) < 0
        R1 = -R1;
    end
    if det(R2) < 0
        R2 = -R2;
    end
    t = [u3, u3, -u3, -u3];
    R = cat(3, R1, R2, R1, R2);
    % Pick the correct combination by enforcing positive chirality.
    % Follow the paper: Triangulation. Section 5.3 midpoint method.
    % https://perception.inrialpes.fr/Publications/1997/HS97/HartleySturm-cviu97.pdf
    npd = zeros(4, 1);
    P = zeros(3, size(inliers, 2), 4);
    Q = zeros(3, size(inliers, 2), 4);
    % Define camera matrix 1.
    P1 = K * [eye(3), zeros(3, 1)];
    for j = 1 : 4
        % Define camera matrix 2.
        P2 = K * [R(:, :, j), t(:, j)];
        M1 = P1(1 : 3, 1 : 3);
        M2 = P2(1 : 3, 1 : 3);
        c1 = -M1 \ P1(:, 4);
        c2 = -M2 \ P2(:, 4);
        for k = 1 : size(inliers, 2)
            u1 = [pointsSelectedInliers(1, k); pointsSelectedInliers(2, k); 1];
            u2 = [pointsNextSelectedInliers(1, k); pointsNextSelectedInliers(2, k); 1];
            a1 = M1 \ u1;
            a2 = M2 \ u2;
            A = [a1, -a2];
            y = c2 - c1;
            alpha = (A' * A) \ A' * y;
            p = (c1 + alpha(1) * a1 + c2 + alpha(2) * a2) / 2;
            P(:, k, j) = p;
            Q(:, k, j) = (p' * R(:, :, j) + t(:, j)')';
        end
        % All the points should be in front of the camera. 
        npd(j) = sum(P(3, :, j) > 0 & Q(3, :, j) > 0);
    end
    % Due to the error, choose the best match camera pose combo.
    [~, best] = max(npd);
    RSelected = R(: ,:, best);
    tSelected = t(:, best);
    if norm(tSelected) ~= 0
        tSelected = tSelected ./ norm(tSelected);
    end
    % Car will only march forward.
    if tSelected(3) > 0
        tSelected = - tSelected;
    end
    % Calculate the position and orientation of the camera.
    tSelected2 = -tSelected' * RSelected;
    Rpos = RSelected * Rpos;
    pos = pos + tSelected2 * Rpos;
    % Plot the trajectory.
    figure(1);
    subplot(1, 2, 1);
    title('CameraFeed');
    imshow(J);
    subplot(1, 2, 2);
    title('Trajectory')
    plot(pos(1), pos(3), 'ro');
    % Let the x, y axis plot have the same scale.
    axis equal
    hold on
    % Record video.
    frame = getframe(gcf);
    writeVideo(vid, frame); 
    pause(0.001)
end
close(vid)