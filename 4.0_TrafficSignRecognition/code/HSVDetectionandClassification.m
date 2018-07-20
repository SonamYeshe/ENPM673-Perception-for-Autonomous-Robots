close all
% Generate a subpath for the 2 given codes.
addpath(genpath('./../input/'));
% Extract images dataset.
images.filename = ls('./../input/*.jpg');
numImages = size(images.filename, 1); 
% Open video writer, prepare for recording.
vid = VideoWriter('TrafficSignDetection', 'MPEG-4');
vid.FrameRate = 30;
open(vid);
for i = 1 : numImages
    i
    img = imread(images.filename(i, :));
    % Denoise the image.
    imgDenoised = imgaussfilt(img, 0.8);
    % Extract R, G, B channels.
    R = imgDenoised(:, :, 1);
    G = imgDenoised(:, :, 2);
    B = imgDenoised(:, :, 3);
    % Normalize the contrast.
    RGBStretchlim = stretchlim(imgDenoised);
    RContrasted = imadjust(R, RGBStretchlim(:, 1), []);
    GContrasted = imadjust(G, RGBStretchlim(:, 2), []);
    BContrasted = imadjust(B, RGBStretchlim(:, 3), []);
    recombinedRGBImage = cat(3, RContrasted, GContrasted, BContrasted);
    % Create a mask focus on top 2/3 of the images.
    [m, n, ~] = size(img);
    x = [1, n, n, 1];
    y = [1, 1, 2 * m / 3, 2 * m / 3];
    maskROI = poly2mask(x, y, m, n);
    % Separate H, S, V channel.
    imgHSV = rgb2hsv(recombinedRGBImage);
    H = imgHSV(:, :, 1);
    S = imgHSV(:, :, 2);
    V = imgHSV(:, :, 3);
    % Set red color HSV thresholds.
    maskR = ((H < 0.028 | H > 0.98) & S > 0.68 & V > 0.6)  | ((H < 0.02 | H > 0.95) & S > 0.6 & V > 0.15);
    structelem = strel('disk', 2);
    maskR = imdilate(maskR, structelem);
    maskR = bwpropfilt(maskR, 'Area', [200 8000]);
    statsR = regionprops(maskR, 'Centroid');
    % Connect close area.
    centersConnectedPointsRx = [];
    centersConnectedPointsRy = [];
    if ~isempty(statsR)
        C = combnk(1 : length(statsR), 2);
        for j = 1 : size(C, 1)
            distTmp = norm(statsR(C(j, 1)).Centroid - statsR(C(j, 2)).Centroid);
            if distTmp < 75
                NumberNewPoints = round(distTmp);
                centersConnectedPointsRx = cat(2, centersConnectedPointsRx, linspace(statsR(C(j, 1)).Centroid(1), statsR(C(j, 2)).Centroid(1), NumberNewPoints+2));
                centersConnectedPointsRy = cat(2, centersConnectedPointsRy, linspace(statsR(C(j, 1)).Centroid(2), statsR(C(j, 2)).Centroid(2), NumberNewPoints+2));
            end
        end
    end
    maskR(uint32(centersConnectedPointsRy), uint32(centersConnectedPointsRx)) = 1; % Connect the centroids of close areas.
    % Extract red area properties and delete narrow areas.
    maskR2 = false(m, n);
    maskR2(uint32(centersConnectedPointsRy), uint32(centersConnectedPointsRx)) = 1; % Connect the centroids of close areas.
    statsR = regionprops(maskR, 'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength');
    blob_labelR = bwlabel(maskR);
    for j = 1 : length(statsR)
        if statsR(j).MajorAxisLength / statsR(j).MinorAxisLength < 2
            maskR2(blob_labelR == j) = 1;
        end
    end
	% Set blue color HSV thresholds.
    maskB = (H > 0.45 & H < 0.72 & S > 0.3 & V > 0.97) | (H > 0.51 & H < 0.72 & S > 0.4 & V > 0.87) ...
            | (H > 0.561 & H < 0.634 & S > 0.55 & V > 0.5) | (H > 0.555 & H < 0.7 & S > 0.73 & V > 0.2);
    maskB = imdilate(maskB, structelem);
    maskB = bwpropfilt(maskB, 'Area', [300 10000]);
    % Extract blue area properties and delete narrow areas.
    statsB = regionprops(maskB, 'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength');
    blob_labelB = bwlabel(maskB);
    maskB2 = false(m, n);
    for j = 1 : length(statsB)
        if statsB(j).MajorAxisLength / statsB(j).MinorAxisLength < 1.7
            maskB2(blob_labelB == j) = 1;
        end
    end
    % Combine masks.
    traficSignROI = (maskB2 | maskR2) & maskROI;
%     figure(2);imshow(traficSignROI);
    % Prepare plotting detected contours.
    stats2 = regionprops(traficSignROI, 'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'BoundingBox');
    [B, ~] = bwboundaries(traficSignROI, 8);
    figure(1)
    imshow(img);
    hold on;
    % 8 types of target signs.
    signType = ['00045'; '00021'; '00038'; '00035'; '00017'; '00001'; '00014'; '00019'];
    % Pick only traffic sign's area and classify them.
    chosenAreaIdx = [];
    for k = 1 : size(stats2, 1)
        signArea = imgDenoised(round((stats2(k).BoundingBox(2) - 0 * stats2(k).BoundingBox(4))) : ...
                        round((stats2(k).BoundingBox(2) + 1 * stats2(k).BoundingBox(4))) - 1, ...
                       round((stats2(k).BoundingBox(1) - 0 * stats2(k).BoundingBox(3))) : ...
                        round((stats2(k).BoundingBox(1) + 1 * stats2(k).BoundingBox(3))) - 1, :);
        scaledSignArea = imresize(signArea, imgSize);
        featureTest = extractHOGFeatures(scaledSignArea);
        [predictIndex, score] = predict(classifer,featureTest);
        if ~isempty(score(score > -0.002))
            for j = 1 : 8
                % Demonstrate only the 8 required signs.
                if strcmp(signType(j, :), char(predictIndex)) && round(stats2(k).BoundingBox(1) + 63) < 1628
                    if j == 4
                        chosenAreaIdx = cat(2, chosenAreaIdx, k);
                        % Paste the 18th traffic sign in the training set into the img.
                        [idx, ~] = find(imdsTraining.Labels == char(predictIndex));
                        detectedSign = readimage(imdsTraining, idx(18)); 
                        detectedSign = imresize(detectedSign, imgSize); 
                        img(round(stats2(k).BoundingBox(2) + 1 * stats2(k).BoundingBox(4)) : ...
                        round(stats2(k).BoundingBox(2) + 1 * stats2(k).BoundingBox(4) + 63), ...
                        round(stats2(k).BoundingBox(1)) : round(stats2(k).BoundingBox(1) + 63), :) = detectedSign;
                    else
                        chosenAreaIdx = cat(2, chosenAreaIdx, k);
                        % Paste the 1st traffic sign in the training set into the img.
                        [idx, ~] = find(imdsTraining.Labels == char(predictIndex));
                        detectedSign = readimage(imdsTraining, idx(1)); 
                        detectedSign = imresize(detectedSign, imgSize); 
                        img(round(stats2(k).BoundingBox(2) + 1 * stats2(k).BoundingBox(4)) : ...
                        round(stats2(k).BoundingBox(2) + 1 * stats2(k).BoundingBox(4) + 63), ...
                        round(stats2(k).BoundingBox(1)) : round(stats2(k).BoundingBox(1) + 63), :) = detectedSign;
                    end
                end
            end
        end
    end
    % Refresh the img with replaced traffic signs from traininng set.
    imshow(img);
    % Plot bounding box.
    for kk = 1 : length(chosenAreaIdx)
        rectangle('Position', [stats2(chosenAreaIdx(kk)).BoundingBox(1) - 0 * stats2(chosenAreaIdx(kk)).BoundingBox(3), ...
                   stats2(chosenAreaIdx(kk)).BoundingBox(2) - 0 * stats2(chosenAreaIdx(kk)).BoundingBox(4), ...
                   1 * stats2(chosenAreaIdx(kk)).BoundingBox(3), 1 * stats2(chosenAreaIdx(kk)).BoundingBox(4)], ...
                  'EdgeColor', 'g', 'LineWidth', 2);
    end
%     % Plot bounding box.
%     if correctDetect
%         for k = 1 : size(stats2, 1)
%             rectangle('Position', [stats2(k).BoundingBox(1) - 0 * stats2(k).BoundingBox(3), ...
%                        stats2(k).BoundingBox(2) - 0 * stats2(k).BoundingBox(4), ...
%                        1 * stats2(k).BoundingBox(3), 1 * stats2(k).BoundingBox(4)], ...
%                       'EdgeColor', 'g', 'LineWidth', 2);
%     %         plot(stats2(k).Centroid(1), stats2(k).Centroid(2), 'g*');
%         end
%     end
    % Plot classified sign in the image.
    hold off
    pause(0.005);
    % Record video
    frame = getframe(gca);
    writeVideo(vid, frame);
end
close(vid)