function BuoyDetection(frameID)
    addpath('../Part2/');
    addpath('../../Images/TestSet/Frames/');
    [YBuoyMean, YBuoyStd, RBuoyMean, RBuoyStd, GBuoyMean, GBuoyStd] = EMParamExtractor(1);
    % Sort the mean values to decide which one represent which color.
    YBuoyMeanSorted = sort(YBuoyMean);
    RBuoyMeanSorted = sort(RBuoyMean);
    GBuoyMeanSorted = sort(GBuoyMean);
    YBuoyStdSorted = zeros(3, 1);
    RBuoyStdSorted = zeros(3, 1);
    GBuoyStdSorted = zeros(3, 1);
    for i = 1 : 3
        for j = 1 : 3
            if YBuoyMeanSorted(i) == YBuoyMean(j)
                YBuoyStdSorted(i) = YBuoyStd(j);
            end
            if RBuoyMeanSorted(i) == RBuoyMean(j)
                RBuoyStdSorted(i) = RBuoyStd(j);
            end
            if GBuoyMeanSorted(i) == GBuoyMean(j)
                GBuoyStdSorted(i) = GBuoyStd(j);
            end
        end
    end
    % Load the image frame and extract the RGB matrices.
    fileName = sprintf('../../Images/TestSet/Frames/%s.jpg', frameID);
    frame = imread(fileName);
    % [m, n, ~] = size(frame);
    R = frame(:, :, 1);
    G = frame(:, :, 2);
    B = frame(:, :, 3);
    %% Calculate Gaussian distribution.
    % Yellow buoy.
    probYR = normcdf(double(R), YBuoyMeanSorted(2), YBuoyStdSorted(2));
    probYG = normcdf(double(G), YBuoyMeanSorted(3), YBuoyStdSorted(3));
    probYB = normcdf(double(B), YBuoyMeanSorted(1), YBuoyStdSorted(1));
    % Red buoy.
    probRR = normcdf(double(R), RBuoyMeanSorted(3), RBuoyStdSorted(3));
    probRG = normcdf(double(G), RBuoyMeanSorted(2), RBuoyStdSorted(2));
    probRB = normcdf(double(B), RBuoyMeanSorted(1), RBuoyStdSorted(1));
    % Green buoy.
    probGR = normcdf(double(R), GBuoyMeanSorted(2), GBuoyStdSorted(2));
    probGG = normcdf(double(G), GBuoyMeanSorted(3), GBuoyStdSorted(3));
    probGB = normcdf(double(B), GBuoyMeanSorted(1), GBuoyStdSorted(1));
    %% Apply masks on 3 buoys.
    se = strel('disk', 5);
    seG = strel('disk', 3);
    % Yellow buoy.
    bw1 = probYR > 0.005 & probYG > 0.005 & probYB < 0.7;
%     figure 
%     imshow(bw1);
    bw1 = bwareaopen(bw1, 40);
    bw1 = imdilate(bw1,se);
    % Red buoy.
    bw2 = probRR > 0.1 & probRB < 0.95;
%     figure 
%     imshow(bw2);
%     bw2 = bwareaopen(bw2, 200);
    bw2 = bwpropfilt(bw2, 'Area', [150 450]);
    bw2 = imdilate(bw2,se);
    % Green buoy.
    bw33 = probGR < 0.95 & probGR > 0.001 & probGG > 0.45 & probGB < 0.985 & probGB > 0.55;
%     figure 
%     imshow(bw33);
    bw33 = bwpropfilt(bw33, 'Area', [50 300]);
    [m,n] = size(bw33);
    blob_label = bwlabel(bw33);
    stats = regionprops(bw33, 'Eccentricity');
    bw3 = false(m, n);
    for i = 1 : length(stats)
        if stats(i).Eccentricity < 0.98
            bw3(blob_label == i) = 1;
        end
    end
    bw3 = imdilate(bw3, seG);
    % Compose binary image for buoys.
    bw = bw1 | bw2 | bw3;
    figure 
    imshow(bw);
    savingName1 = sprintf('binary_%s.jpg', frameID);
    saveas(gcf, savingName1);
    %% Plot the contour and centroid position on top of the image.
    figure
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
    % Save as .jpg.
    savingName2 = sprintf('out_%s.jpg', frameID);
    saveas(gcf, savingName2);
end