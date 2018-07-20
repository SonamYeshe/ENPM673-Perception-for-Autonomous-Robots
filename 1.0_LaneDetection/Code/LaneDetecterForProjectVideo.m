clc
close all
clear all

%% Prepare video and pictures convertions.
% Read video.
v = VideoReader('../Input/project_video.mp4');
numberOfFrames = v.NumberOfFrames;
% Open video writer, prepare for recording.
vid = VideoWriter('LaneDetectionForProjectVideo', 'MPEG-4');
vid.FrameRate = 30;
open(vid);
% Setup global variable for the 4 points used to plot the left and right line in order to eliminate the sudden change of the line and compensate for the missing lines dur to the shadow covering.
leftLineXPrev = [];
rightLineXPrev = [];
pLeftValuePrev = [];
pRightValuePrev = [];

for i = 1 : numberOfFrames
    %% Denoise and enhance the pic.
    rgbImage = read(v, i);
    i % Showing what is the step under processing now.
    % Extract color channels.
    redChannel = rgbImage(:, :, 1); % Red channel
    greenChannel = rgbImage(:, :, 2); % Green channel
    blueChannel = rgbImage(:, :, 3); % Blue channel
    % Denoise all the channels
    denoisedRedChannel = medfilt2(redChannel, [3 3]);
    denoisedGreenChannel = medfilt2(greenChannel, [3 3]);
    denoisedBlueChannel = medfilt2(blueChannel, [3 3]);
    % Increase contrast
    imadjustedRedChannel = imadjust(denoisedRedChannel);
    imadjustedGreenChannel = imadjust(denoisedGreenChannel);
    imadjustedBlueChannel = imadjust(denoisedBlueChannel);
    % Recombine the individual color channels to create the original RGB image again.
    recombinedRGBImage1 = cat(3, denoisedRedChannel, denoisedGreenChannel, denoisedBlueChannel);
    recombinedRGBImage2 = cat(3, imadjustedRedChannel, imadjustedGreenChannel, imadjustedBlueChannel);

    %% Find yellow line.
    % Transfer RGB image to HSV.
    hsvImage = rgb2hsv(recombinedRGBImage1);
    hImage = hsvImage(:,:,1); % Hue.
    sImage = hsvImage(:,:,2); % Saturation.
    vImage = hsvImage(:,:,3); % Value(Brightness).
    % Setup threashold for yellow color.
    hueThresholdLow = 0.10;
    hueThresholdHigh = 0.14;
    saturationThresholdLow = 0.4;
    saturationThresholdHigh = 1;
    valueThresholdLow = 0.8;
    valueThresholdHigh = 1.0;
    % Setup and apply yellow color mask.
    hueMask1 = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
    saturationMask1 = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
    valueMask1 = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);
    yellowObjectsMask = bwareaopen(uint8(hueMask1 & saturationMask1 & valueMask1), 200);

    %% Find white line.
    % Transfer RGB image to HSV.
    hsvImage = rgb2hsv(recombinedRGBImage2);
    hImage = hsvImage(:,:,1);
    sImage = hsvImage(:,:,2);
    vImage = hsvImage(:,:,3);
    % Reset threashold for white color.
    hueThresholdLow = 0.0;
    hueThresholdHigh = 1.0;
    saturationThresholdLow = 0.0;
    saturationThresholdHigh = 0.07;
    valueThresholdLow = 0.9;
    valueThresholdHigh = 1.0;
    % Reset and apply white color mask.
    hueMask2 = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
    saturationMask2 = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
    valueMask2 = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);
    whiteObjectsMask = bwareaopen(uint8 (hueMask2 & saturationMask2 & valueMask2), 5);

    %% Extract the left and right lines' edge.
    % Combine yellow and white line.
    BW1 = whiteObjectsMask | yellowObjectsMask;
    % Eliminate car noise.
    BW2 = bwpropfilt(BW1, 'Area', [0 5000]);
    % Canny's edge detection.
    BW3 = edge(BW2, 'Canny', 0.4);
    % Create a mask to focus on the driving lane.
    x=[500 780 1160 120];
    yIntrestedLow = 460;
    yIntrestedHigh = 680;
    y=[yIntrestedLow yIntrestedLow yIntrestedHigh yIntrestedHigh];
    m=size(BW3, 1); 
    n=size(BW3, 2);
    mask1 = poly2mask(x, y, m, n);
    % Create a mask to ignore the near front area of the car.
    x=[625 655 850 430];
    y=[500 500 720 720];
    m=size(BW3, 1); 
    n=size(BW3, 2);
    mask2 = poly2mask(x, y, m, n);
    mask2 = 1 - mask2;
    BW4 = BW3 & mask1 & mask2;

    %% Get Hough lines.
    % H: Hough transform matrix.
    % T: \theta values.
    % R: \rou values.
    [H, T, R] = hough(BW4, 'RhoResolution', 0.5, 'ThetaResolution', 0.5);
    % 10: means preserving 10 peaks.
    % threshold: Minimum value to be considered a peak.
    % ceil(): Round up to the next integer.
    P  = houghpeaks(H, 12, 'threshold', ceil(0.1 * max(H(:))));
    % FillGap: Distance between two line segments associated with the same Hough transform bin.
    lines = houghlines(BW4, T, R, P, 'FillGap', 200, 'MinLength', 10);
    
    %% Store the left and right line points seperately.
    leftpoints = struct([]);
    rightpoints = struct([]);
    n = length(lines);
    i = 1;
    j = 1;
    while n > 0
        % Group the left lines with positive theta values and ignore the odd lines.
        if lines(n).theta > 0 && lines(n).theta < 70 % Left line
            leftpoints(i).points = lines(n).point1;
            i = i + 1;
            leftpoints(i).points = lines(n).point2;
            i = i + 1;
            n = n - 1;
        % Group the right lines with positive theta values and ignore the odd lines.
        elseif lines(n).theta < 0 && lines(n).theta > - 70 % Right line  
            rightpoints(j).points = lines(n).point1;
            j = j + 1;
            rightpoints(j).points = lines(n).point2;
            j = j + 1;
            n = n - 1;
        else
            n = n - 1;
        end
    end

    %% Store the points from left and right lines' x, y values seperately.
    % Store left lines' x, y values.
    leftLineX = [];
    leftLineY = [];
    lCount = length(leftpoints);
    leftCount = lCount / 2;
    if lCount > 0
        for k = 1 : leftCount
            leftLineX = cat(1, leftLineX, leftpoints(2 * k - 1).points(1));
            leftLineX = cat(1, leftLineX, leftpoints(2 * k).points(1));
            leftLineY = cat(1, leftLineY, leftpoints(2 * k - 1).points(2));
            leftLineY = cat(1, leftLineY, leftpoints(2 * k).points(2));
        end
    end
    % Store right lines' x, y values.
    rightLineX = [];
    rightLineY = [];
    rCount = length(rightpoints);
    rightCount = rCount / 2;
    if rCount > 0
        for k = 1 : rightCount
            rightLineX = cat(1, rightLineX, rightpoints(2 * k - 1).points(1));
            rightLineX = cat(1, rightLineX, rightpoints(2 * k).points(1));
            rightLineY = cat(1, rightLineY, rightpoints(2 * k - 1).points(2));
            rightLineY = cat(1, rightLineY, rightpoints(2 * k).points(2));
        end
    end
    
    %% Compensate the missing lines in some frames while it's covered by shadow.
    if isempty(leftLineX)
        leftLineX = leftLineXPrev;
        pLeftValue = pLeftValuePrev;
    else
        % Linear regression for the left and right line to cancel out outliers by polyfit.
        pLeft = polyfit(leftLineX, leftLineY, 1);
        pLeftValue = polyval(pLeft, leftLineX);
    end
    
    if isempty(rightLineX)
        rightLineX = rightLineXPrev;
        pRightValue = pRightValuePrev;
    else
        % Linear regression for the right and right line to cancel out outliers by polyfit.
        pRight = polyfit(rightLineX, rightLineY, 1);
        pRightValue = polyval(pRight, rightLineX);
    end    
    
    %% Extend the left and right lines
    % Calculate slope and intersect value with y axis of left and right lines.
    kLeft = - abs( (pLeftValue(2) - pLeftValue(1)) / (leftLineX(2) - leftLineX(1)) );
    bLeft = pLeftValue(1) - kLeft * leftLineX(1);
    kRight = abs( (pRightValue(2) - pRightValue(1)) / (rightLineX(2) - rightLineX(1)) );
    bRight = pRightValue(1) - kRight * rightLineX(1); 
    % Create the new plotting edge points.
    plotLeftX = [(yIntrestedLow - bLeft) / kLeft; (yIntrestedHigh - bLeft) / kLeft];
    plotLeftY = [yIntrestedLow; yIntrestedHigh];
    plotRightX = [(yIntrestedLow - bRight) / kRight; (yIntrestedHigh - bRight) / kRight];
    plotRightY = [yIntrestedLow; yIntrestedHigh];
    
    %% Using low-pass filter to smooth the lines between each other.
    tau_slope = 0.96;
    tau_offset = 0.96;
    if ~isempty(leftLineXPrev)
        plotLeftX(1:2) = tau_slope * leftLineXPrev(1:2) + (1 - tau_slope) * plotLeftX(1:2);
        plotLeftY(1:2) = tau_offset * pLeftValuePrev(1:2) + (1 - tau_offset) * plotLeftY(1:2);
    end
    if ~isempty(rightLineXPrev)
        plotRightX(1:2) = tau_slope * rightLineXPrev(1:2) + (1 - tau_slope) * plotRightX(1:2);
        plotRightY(1:2) = tau_offset * pRightValuePrev(1:2) + (1 - tau_offset) * plotRightY(1:2);
    end
    % Update the global variables for final plotting.
    leftLineXPrev = plotLeftX(1:2);
    rightLineXPrev = plotRightX(1:2);
    pLeftValuePrev = plotLeftY(1:2);
    pRightValuePrev = plotRightY(1:2);
    
    %% Fill in the lane with transparent green color. (Stackoverflow.)
    laneAreaX = [plotLeftX(1), plotLeftX(2), plotRightX(2), plotRightX(1)];
    laneAreaY = [plotLeftY(1), plotLeftY(2), plotRightY(2), plotRightY(1)];
    BW5 = poly2mask(laneAreaX, laneAreaY, size(rgbImage,1), size(rgbImage,2));
    clr = [0 255 0]; % Green color.
    a = 0.25; % Blending factor.
    % Create transparent green mask.
    z = false(size(BW5));
    laneMask = cat(3, BW5, z, z); 
    rgbImage(laneMask) = a * clr(1) + (1 - a) * rgbImage(laneMask);
    laneMask = cat(3, z, BW5, z); 
    rgbImage(laneMask) = a * clr(2) + (1 - a) * rgbImage(laneMask);
    laneMask = cat(3, z, z, BW5); 
    rgbImage(laneMask) = a * clr(3) + (1 - a) * rgbImage(laneMask);    
    
    %% Plot (arrow.m is downloaded from internet)
    figure('visible', 'off'), imshow(rgbImage), hold on
    plot(plotLeftX, plotLeftY, 'LineWidth', 5, 'Color', 'red');
    plot(plotRightX, plotRightY, 'LineWidth', 5, 'Color', 'red');
    % Create arrow to predict turns.
    % ArrowX1 = (plotLeftX(2) + plotRightX(2)) / 2; 
    % It's so wierd to see the direction line defined by the algorithm...
    % Forgive me, use the bottom middle point looks much better...
    ArrowX1 = size(rgbImage,2) / 2;
    ArrowX2 = (plotLeftX(1) + plotRightX(1)) / 2;
    ArrowY1 = (plotLeftY(2) + plotRightY(2)) / 2;
    ArrowY2 = (plotLeftY(1) + plotRightY(1)) / 2;
    arrow([ArrowX1, ArrowY1], [ArrowX2, ArrowY2], 'EdgeColor', 'g', 'FaceColor', 'g', 'wid', 4, 'tip', 30, 'page', 20);
    
    %% Record video
    frame = getframe(gca);
    writeVideo(vid, frame); 
    
end

close(vid)