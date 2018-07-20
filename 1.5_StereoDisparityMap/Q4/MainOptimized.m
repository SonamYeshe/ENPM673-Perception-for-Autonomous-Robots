%% Improve the baseline using: 1. Adaptive choice of the window, 2. Change SSD to the Normalized Cross-correlation algorithm.
% References: 
% 1. Stereo Vision Tutorial - Part I:    http://mccormickml.com/2014/01/10/stereo-vision-tutorial-part-i/
% 2. An Adaptive Window Stereo Matching Based on Gradient:    https://www.atlantis-press.com/php/download_paper.php?id=10340
% 3. Normalized 2-D cross-correlation:     https://www.mathworks.com/help/images/ref/normxcorr2.html

clear all
clc

imgLeft = imread('./../images-midterm/tsukuba_l.png');
imgRight = imread('./../images-midterm/tsukuba_r.png');

% Preprocessing the images.
imgLeft = medfilt2(imgLeft);
imgRight = medfilt2(imgRight);
imgLeft = imadjust(imgLeft);
imgRight = imadjust(imgRight);

% Calculate gradients to adapt different windows.
G = imgradient(imgRight);
[Gx, Gy] = imgradientxy(imgRight);

% Search limit along the epipolar scan line.
disparityMax = 15; % dummy, will redifine this later according to the gradient.
% Define window size options as 7x7, 7x21, 21x7, 21x21.
halfWindowSizeSmall = 3;
halfWindowSizeLarge = 10;
% Predefine the window location.
windowLeft = 0;
windowRight = 0;
windowUp = 0;
windowDown = 0;

[m, n] = size(imgLeft);
disparityMatrix = zeros(m, n);
% Threshold of gradients for adaptive window decision.
alpha = 25;
beta = 5;
for i = 1 : n
    for j = 1 : m
        % Define the size of adaptive windows.
        if G(j, i) > alpha && (Gx(j, i) - Gy(j, i)) > beta
            windowLeft = max(i - halfWindowSizeSmall, 1);
            windowRight = min(i + halfWindowSizeSmall, n);
            windowUp = max(j - halfWindowSizeLarge, 1);
            windowDown = min(j + halfWindowSizeLarge, m);
            disparityMax = 10;
        elseif G(j, i) > alpha && (Gy(j, i) - Gx(j, i)) > beta
            windowLeft = max(i - halfWindowSizeLarge, 1);
            windowRight = min(i + halfWindowSizeLarge, n);
            windowUp = max(j - halfWindowSizeSmall, 1);
            windowDown = min(j + halfWindowSizeSmall, m);
            disparityMax = 15;
        elseif G(j, i) <= alpha
            windowLeft = max(i - halfWindowSizeLarge, 1);
            windowRight = min(i + halfWindowSizeLarge, n);
            windowUp = max(j - halfWindowSizeLarge, 1);
            windowDown = min(j + halfWindowSizeLarge, m);
            disparityMax = 15;
        else
            windowLeft = max(i - halfWindowSizeSmall, 1);
            windowRight = min(i + halfWindowSizeSmall, n);
            windowUp = max(j - halfWindowSizeSmall, 1);
            windowDown = min(j + halfWindowSizeSmall, m);
            disparityMax = 10;
        end
        % Transform window edge to integer to represent index.
        windowLeft = uint16(windowLeft);
        windowRight = uint16(windowRight);
        windowUp = uint16(windowUp);
        windowDown = uint16(windowDown);
        % Select the search area in the left image.
        imgRightWindow = imgRight(windowUp : windowDown, windowLeft : windowRight);
        if windowRight + disparityMax <= n
            imgLeftWindow = imgLeft(windowUp : windowDown, windowLeft : windowRight + disparityMax);
        else
            imgLeftWindow = imgLeft(windowUp : windowDown, windowLeft : windowRight);
        end
        % Calculate Cross-correlation to find the template in the image.
        c = normxcorr2(imgRightWindow, imgLeftWindow);
        [ypeak, xpeak] = find(c==max(c(:)));
        % Restrict the similar template has to be totoally inside the
        % search area.
        if xpeak(1) < size(imgRightWindow,2)
            xpeak(1) = size(imgRightWindow,2);
        elseif xpeak(1) > size(imgLeftWindow,2)
            xpeak(1) = size(imgLeftWindow,2);
        end
        disparityMatrix(j, i) = xpeak(1) - size(imgRightWindow,2);
    end
end
figure(1);
imshow(disparityMatrix,[]);
axis image;
colormap(gca,jet);
colorbar;
title('Disparity Map 2');