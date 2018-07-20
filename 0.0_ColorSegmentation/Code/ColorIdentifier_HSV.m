%% Denoise Images
% Read in original RGB image.
rgbImage = imread('../Input/TestImgResized.jpg');

% Extract color channels.
redChannel = rgbImage(:,:,1); % Red channel
greenChannel = rgbImage(:,:,2); % Green channel
blueChannel = rgbImage(:,:,3); % Blue channel

% Denoise all the channels
denoisedRedChannel = medfilt2(redChannel,[3 3]);
denoisedGreenChannel = medfilt2(greenChannel,[3 3]);
denoisedBlueChannel = medfilt2(blueChannel,[3 3]);

% % Create an all black channel.
% allBlack = zeros(size(rgbImage, 1), size(rgbImage, 2), 'uint8');
% 
% % Create color versions of the individual color channels.
% just_red = cat(3, denoisedRedChannel, allBlack, allBlack);
% just_green = cat(3, allBlack, denoisedGreenChannel, allBlack);
% just_blue = cat(3, allBlack, allBlack, denoisedBlueChannel);

% Recombine the individual color channels to create the original RGB image again.
recombinedRGBImage = cat(3, denoisedRedChannel, denoisedGreenChannel, denoisedBlueChannel);

% imshowpair(rgbImage, recombinedRGBImage, 'montage');

%% Find total number of colored objects (excluding white and transparent pin)
img_gry = rgb2gray(recombinedRGBImage);
img_gry_clean = medfilt2(img_gry,[3 3]);
img_gry_contrast = imadjust(img_gry_clean);
img_g = imsharpen(img_gry_contrast);
bw_1 = img_g < 155;
bw_2 = bwareaopen(bw_1, 260);

%[m,n] = size(bw_2);
%blob_label = bwlabel(bw_2);
stats = regionprops(logical(bw_2), 'Area');
[pinNumber, whatever] = size(stats);
disp(sprintf('The number of colored objects is %d.', pinNumber));
subplot(3,2,1);
imshow(bw_2);

%% Find individual colored objects - Red, Green, Blue and Yellow
hsvImage = rgb2hsv(recombinedRGBImage);
hImage = hsvImage(:,:,1);
sImage = hsvImage(:,:,2);
vImage = hsvImage(:,:,3);

% yellow
hueThresholdLow = 0.11;
hueThresholdHigh = 0.2;
saturationThresholdLow = 0.5;
saturationThresholdHigh = 1;
valueThresholdLow = 0.8;
valueThresholdHigh = 1.0;

hueMask1 = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);
valueMask=1-valueMask;

yellowObjectsMask = bwareaopen(uint8(hueMask1 & saturationMask & valueMask), 200);
statsYellow = regionprops(logical(yellowObjectsMask), 'Area');
[yellowPinNumber, whateverYellow] = size(statsYellow);
disp(sprintf('The number of yellow objects is %d.', yellowPinNumber));

subplot(3,2,3);
imshow(yellowObjectsMask, []);

% blue
hueThresholdLow = 0.58;
hueThresholdHigh = 0.73;

hueMask2 = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
blueObjectsMask = bwareaopen(uint8(hueMask2 & saturationMask & valueMask), 200);
statsBlue = regionprops(logical(blueObjectsMask), 'Area');
[bluePinNumber, whateverBlue] = size(statsBlue);
disp(sprintf('The number of blue objects is %d.', bluePinNumber));

subplot(3,2,4);
imshow(blueObjectsMask, []);

% green
hueThresholdLow = 0.25;
hueThresholdHigh = 0.5;

hueMask3 = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
greenObjectsMask = bwareaopen(uint8(hueMask3 & saturationMask & valueMask), 50);
statsGreen = regionprops(logical(greenObjectsMask), 'Area');
[greenPinNumber, whateverGreen] = size(statsGreen);
disp(sprintf('The number of green objects is %d.', greenPinNumber));

subplot(3,2,5);
imshow(greenObjectsMask, []);

% red
hueThresholdLow = 0;
hueThresholdHigh = 0.1;

hueMask4 = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
redObjectsMask = bwareaopen(uint8(hueMask4 & saturationMask & valueMask), 30);
statsRed = regionprops(logical(redObjectsMask), 'Area');
[redPinNumber, whateverRed] = size(statsRed);
disp(sprintf('The number of red objects is %d.', redPinNumber));

subplot(3,2,6);
imshow(redObjectsMask, []);
