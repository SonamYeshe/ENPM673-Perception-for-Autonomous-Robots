clear all
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

im = imread('../../Images/TestSet/Frames/019.jpg');
[m, n, ~] = size(im);
%% Yellow buoy
prob_YR = normcdf(double(im(:,:,1)), YBuoyRMean, YBuoyRStd);
prob_YG = normcdf(double(im(:,:,2)), YBuoyGMean, YBuoyGStd);
prob_YB = normcdf(double(im(:,:,3)), YBuoyBMean, YBuoyBStd);
%% Red buoy
prob_RR = normcdf(double(im(:,:,1)), RBuoyRMean, RBuoyRStd);
prob_RG = normcdf(double(im(:,:,2)), RBuoyGMean, RBuoyGStd);
prob_RB = normcdf(double(im(:,:,3)), RBuoyBMean, RBuoyBStd);
%% Green buoy
prob_GR = normcdf(double(im(:,:,1)), GBuoyRMean, GBuoyRStd);
prob_GG = normcdf(double(im(:,:,2)), GBuoyGMean, GBuoyGStd);
prob_GB = normcdf(double(im(:,:,3)), GBuoyBMean, GBuoyBStd);

structelem = strel('disk', 5);
%% Yellow buoy
bw1 = prob_YR > 0.01 & prob_YG > 0.01 & prob_YB < 0.7;
bw1 = bwareaopen(bw1,120);
bw1 = imdilate(bw1,structelem);
% figure(1)
% imshow(bw1);

%% Red buoy
bw2 = prob_RR > 0.1 & prob_RB < 0.95;
bw2 = bwareaopen(bw2,50);
bw2 = imdilate(bw2,structelem);
% figure(2)
% imshow(bw2);

%% Green buoy
bw3 = prob_GR < 0.9 & prob_GG > 0.1 & prob_GB < 0.7;
bw3 = bwareaopen(bw3,50);
bw3 = imdilate(bw3,structelem);
% figure(3)
% imshow(bw3);

imshow(im);
%% Get the centroids of the isolated circular blobs
stats2 = regionprops(bw1,'Area','Centroid');
%% Plot the contour and centroid position on top of the image
B = bwboundaries(bw1, 8);
hold on;
for k = 1 : length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2)
end
for i = 1 : length(stats2)
    plot(stats2(i).Centroid(1), stats2(i).Centroid(2), 'y*');
end