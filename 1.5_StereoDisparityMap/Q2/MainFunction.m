clear all
clc
img = imread('./../images-midterm/low-contrast-ex.png');
% Generate a histogram.
[counts, binLocations] = imhist(img);
% Let sum(ratio) == 255.
ratio = 255 / sum(counts) * counts;
% Generate second histogram.
counts2 = zeros(256, 1);
counts2(1) = ratio(1);
for i = 2 : 256
    counts2(i) = counts2(i - 1) + ratio(i);
end
% Create a new image.
imgNormalized = uint8(zeros(size(img, 1), size(img, 2)));
for i = 1 : size(img, 1)
    for j = 1 : size(img, 2)
        k = img(i, j);
        imgNormalized(i, j) = counts2(k);
    end
end
imhist(imgNormalized)
figure (2)
imshow(imgNormalized)

