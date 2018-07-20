clear all
clc

imgLeft = imread('./../images-midterm/tsukuba_l.png');
imgRight = imread('./../images-midterm/tsukuba_r.png');
% Search limit along the epipolar scan line.
disparityMax = 25;
% Define a odd number as the window size.
windowSize = 25;
halfWindowSize = (windowSize - 1) / 2;
% Predefine the window location.
windowLeft = 0;
windowRight = 0;
windowUp = 0;
windowDown = 0;

[m, n] = size(imgLeft);
disparityMatrix = zeros(m, n);
for i = 1 : n
    % Window definition for columns (including corners).
    if i <= halfWindowSize
        windowLeft = 1;
        windowRight = i + halfWindowSize;
    elseif i >= (n - halfWindowSize) 
        windowLeft = i - halfWindowSize;
        windowRight = n;
    else
        windowLeft = i - halfWindowSize;
        windowRight = i + halfWindowSize;
    end
    for j = 1 : m
        % Window definition for rows (including corners).
        if j <= halfWindowSize
            windowUp = 1;
            windowDown = j + halfWindowSize;
        elseif j >= (m - halfWindowSize) 
            windowUp = j - halfWindowSize;
            windowDown = m;
        else
            windowUp = j - halfWindowSize;
            windowDown = j + halfWindowSize;
        end
        windowLeft = uint16(windowLeft);
        windowRight = uint16(windowRight);
        windowUp = uint16(windowUp);
        windowDown = uint16(windowDown);
        % Calculate Sum of Squared Differences.
        imgRightWindow = imgRight(windowUp : windowDown, windowLeft : windowRight);
        disparity = 10000000000000000;
        pairedK = 0;
        for k = 1 : disparityMax
            if windowRight + k <= n
                imgLeftWindow = imgLeft(windowUp : windowDown, windowLeft + k : windowRight + k);
            else
                imgLeftWindow = imgLeft(windowUp : windowDown, windowLeft : windowRight);
            end
            tempDisparity = sum(sum((imgLeftWindow - imgRightWindow).^2, 1), 2);
            if tempDisparity < disparity
                disparity = tempDisparity;
                pairedK = k;
            end
            disparityMatrix(j, i) = pairedK - 1;
        end
    end
end
figure(1);
imshow(disparityMatrix,[]);
axis image;
colormap(gca,jet);
colorbar;
title('Disparity Map');