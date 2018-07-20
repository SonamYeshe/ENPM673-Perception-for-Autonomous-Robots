clear all
clc
close all
% Open video writer, prepare for recording.
vid = VideoWriter('segmentedFrames01-43', 'MPEG-4');
vid.FrameRate = 10;
open(vid);
% Calculate mean and standard deviantion.
load '../../Images/TrainingSet/YellowSamples'
YBuoyRMean = mean(Samples(:, 1));
YBuoyGMean = mean(Samples(:, 2));
YBuoyBMean = mean(Samples(:, 3));
YBuoyRStd = std(double(Samples(:, 1)));
YBuoyGStd = std(double(Samples(:, 2)));
YBuoyBStd = std(double(Samples(:, 3)));
load '../../Images/TrainingSet/RedSamples'
RBuoyRMean = mean(Samples(:, 1));
RBuoyGMean = mean(Samples(:, 2));
RBuoyBMean = mean(Samples(:, 3));
RBuoyRStd = std(double(Samples(:, 1)));
RBuoyGStd = std(double(Samples(:, 2)));
RBuoyBStd = std(double(Samples(:, 3)));
load '../../Images/TrainingSet/GreenSamples'
GBuoyRMean = mean(Samples(:, 1));
GBuoyGMean = mean(Samples(:, 2));
GBuoyBMean = mean(Samples(:, 3));
GBuoyRStd = std(double(Samples(:, 1)));
GBuoyGStd = std(double(Samples(:, 2)));
GBuoyBStd = std(double(Samples(:, 3)));
% Extract images dataset.
images.filename = ls('../../Images/TestSet/Frames/*.jpg');
numImages = size(images.filename, 1); 
for i = 1 : 43
    frame = imread(images.filename(i, :));
    % [m, n, ~] = size(frame);
    R = frame(:, :, 1);
    G = frame(:, :, 2);
    B = frame(:, :, 3);
    %% Calculate Gaussian distribution.
    % Yellow buoy.
    probYR = normcdf(double(R), YBuoyRMean, YBuoyRStd);
    probYG = normcdf(double(G), YBuoyGMean, YBuoyGStd);
    probYB = normcdf(double(B), YBuoyBMean, YBuoyBStd);
    % Red buoy.
    probRR = normcdf(double(R), RBuoyRMean, RBuoyRStd);
    probRG = normcdf(double(G), RBuoyGMean, RBuoyGStd);
    probRB = normcdf(double(B), RBuoyBMean, RBuoyBStd);
    % Green buoy.
    probGR = normcdf(double(R), GBuoyRMean, GBuoyRStd);
    probGG = normcdf(double(G), GBuoyGMean, GBuoyGStd);
    probGB = normcdf(double(B), GBuoyBMean, GBuoyBStd);
    %% Apply masks on 3 buoys.
    se = strel('disk', 5);
    % Yellow buoy.
    bw1 = probYR > 0.01 & probYG > 0.01 & probYB < 0.7;
    bw1 = bwareaopen(bw1, 120);
    bw1 = imdilate(bw1, se);
    % Red buoy.
    bw2 = probRR > 0.1 & probRB < 0.95;
    bw2 = bwareaopen(bw2, 120);
    bw2 = imdilate(bw2, se);
    % Green buoy.
    bw3 = probGR < 0.9 & probGG > 0.1 & probGB < 0.7;
    bw3 = bwareaopen(bw3, 120);
    bw3 = imdilate(bw3, se);
    %% Plot the contour and centroid position on top of the image.
    imshow(frame);
    hold on;
    % Yellow buoy.
    stats1 = regionprops(bw1, 'Centroid');
    B1 = bwboundaries(bw1, 8);
    for k = 1 : length(B1)
        boundary1 = B1{k};
        plot(boundary1(:, 2), boundary1(:, 1), 'y', 'LineWidth', 2)
    end
    for ii = 1 : length(stats1)
        plot(stats1(ii).Centroid(1), stats1(ii).Centroid(2), 'y*');
    end
    % Red buoy.
    stats2 = regionprops(bw2, 'Centroid');
    B2 = bwboundaries(bw2, 8);
    hold on;
    for k = 1 : length(B2)
        boundary2 = B2{k};
        plot(boundary2(:, 2), boundary2(:, 1), 'r', 'LineWidth', 2)
    end
    for jj = 1 : length(stats2)
        plot(stats2(jj).Centroid(1), stats2(jj).Centroid(2), 'r*');
    end
    % Green buoy.
    stats3 = regionprops(bw3, 'Centroid');
    B3 = bwboundaries(bw3, 8);
    hold on;
    for k = 1 : length(B3)
        boundary3 = B3{k};
        plot(boundary3(:, 2), boundary3(:, 1), 'g', 'LineWidth', 2)
    end
    for kk = 1 : length(stats3)
        plot(stats3(kk).Centroid(1), stats3(kk).Centroid(2), 'g*');
    end
    %% Record video
    frameVid = getframe(gca);
    writeVideo(vid, frameVid); 
end
close(vid)