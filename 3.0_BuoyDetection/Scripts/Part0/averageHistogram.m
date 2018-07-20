clear all

% Calculate average histogram for yellow buoy.
filenameBase = '../../Images/TrainingSet/CroppedBuoys/Y_';
x = (0 : 1 : 255);
avgR = zeros(256, 1);
avgG = zeros(256, 1);
avgB = zeros(256, 1);
for i = 1 : 43
    filenameNum =sprintf('%d.jpg',i);
    fullFilename = strcat(filenameBase, filenameNum);
    img = imread(fullFilename);
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
    % Discard values equal 0 because they are not buoy area.
    % Imwrite command automatically scale the data by 255. Noise occurs.
    [rhistYellowBuoy, ~] = imhist(R(R > 45));
    [ghistYellowBuoy, ~] = imhist(G(G > 45));
    [bhistYellowBuoy, ~] = imhist(B(B > 45));
    for j = 1 : 256
        avgR(j) = avgR(j) + rhistYellowBuoy(j);
        avgG(j) = avgG(j) + ghistYellowBuoy(j);
        avgB(j) = avgB(j) + bhistYellowBuoy(j);
    end
end
avgR = avgR ./ 100;
avgG = avgG ./ 100;
avgB = avgB ./ 100;
figure (1)
plot(x, avgR, 'Red', x, avgG, 'Green', x, avgB, 'Blue');
xlim([0 255])
title('Histogram for yellow buoy');

% Calculate average histogram for red buoy.
filenameBase = '../../Images/TrainingSet/CroppedBuoys/R_';
x = (0 : 1 : 255);
avgR = zeros(256, 1);
avgG = zeros(256, 1);
avgB = zeros(256, 1);
for i = 1 : 43
    filenameNum =sprintf('%d.jpg',i);
    fullFilename = strcat(filenameBase, filenameNum);
    img = imread(fullFilename);
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
    % Discard values equal 0 because they are not buoy area.
    % Imwrite command automatically scale the data by 255. Noise occurs.
    [rhistRedBuoy, ~] = imhist(R(R > 45));
    [ghistRedBuoy, ~] = imhist(G(G > 45));
    [bhistRedBuoy, ~] = imhist(B(B > 45));
    for j = 1 : 256
        avgR(j) = avgR(j) + rhistRedBuoy(j);
        avgG(j) = avgG(j) + ghistRedBuoy(j);
        avgB(j) = avgB(j) + bhistRedBuoy(j);
    end
end
avgR = avgR ./ 100;
avgG = avgG ./ 100;
avgB = avgB ./ 100;
figure (2)
plot(x, avgR, 'Red', x, avgG, 'Green', x, avgB, 'Blue');
xlim([0 255])
title('Histogram for red buoy');

% Calculate average histogram for green buoy.
filenameBase = '../../Images/TrainingSet/CroppedBuoys/G_';
x = (0 : 1 : 255);
avgR = zeros(256, 1);
avgG = zeros(256, 1);
avgB = zeros(256, 1);
for i = 1 : 43
    filenameNum =sprintf('%d.jpg',i);
    fullFilename = strcat(filenameBase, filenameNum);
    img = imread(fullFilename);
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
    % Discard values equal 0 because they are not buoy area.
    % Imwrite command automatically scale the data by 255. Noise occurs.
    [rhistGreenBuoy, ~] = imhist(R(R > 45));
    [ghistGreenBuoy, ~] = imhist(G(G > 45));
    [bhistGreenBuoy, ~] = imhist(B(B > 45));
    for j = 1 : 256
        avgR(j) = avgR(j) + rhistGreenBuoy(j);
        avgG(j) = avgG(j) + ghistGreenBuoy(j);
        avgB(j) = avgB(j) + bhistGreenBuoy(j);
    end
end
avgR = avgR ./ 43;
avgG = avgG ./ 43;
avgB = avgB ./ 43;
figure (3)
plot(x, avgR, 'Red', x, avgG, 'Green', x, avgB, 'Blue');
xlim([0 255])
title('Histogram for green buoy');