clear all
clc
% Extract and store training data.
imdsTraining = imageDatastore('./../Training', 'IncludeSubfolders',true, 'LabelSource', 'foldernames');    
imgSize = [64, 64];
% Initiate featuresTraining size to store all training dataset's HOG features.
img1 = readimage(imdsTraining, 1);  
scaledImage = imresize(img1,imgSize); 
[featureVector, ~] = extractHOGFeatures(scaledImage);   

% I = im2single(scaledImage);
% hog = vl_hog(I, 4);
% sz = size(hog,1) * size(hog,2) * size(hog,3);
% hogTrans = permute(hog, [2 1 3]);
% hog=reshape(hogTrans,[1 sz]); 

featuresTraining = zeros(length(imdsTraining.Files), size(featureVector,2), 'single');  
% Calculate and store HOG for training dataset.
for i = 1 : length(imdsTraining.Files)    
    imgTraining = readimage(imdsTraining, i);  
    % R channel normalization.
    R = imgTraining(:, :, 1);
    medianR = median(median(R, 2), 1);
    upscaleR = ((R < medianR) .* double(R)) * 128 ./ double(medianR);
    downscaleR = 255 - ((255 - (R > medianR) .* double(R)) * 127 / (255 - double(medianR)));
    downscaleR = max(0, downscaleR);
    maintainR = (R == medianR) .* double(R);
    normalizedR = uint8(upscaleR + downscaleR + maintainR);
    % G channel normalization.
    G = imgTraining(:, :, 2);
    medianG = median(median(G, 2), 1);
    upscaleG = ((G < medianG) .* double(G)) * 128 ./ double(medianG);
    downscaleG = 255 - ((255 - (G > medianG) .* double(G)) * 127 / (255 - double(medianG)));
    downscaleG = max(0, downscaleG);
    maintainG = (G == medianG) .* double(G);
    normalizedG = uint8(upscaleG + downscaleG + maintainG);
    % B channel normalization.
    B = imgTraining(:, :, 3);
    medianB = median(median(B, 2), 1);
    upscaleB = ((B < medianB) .* double(B)) * 128 ./ double(medianB);
    downscaleB = 255 - ((255 - (B > medianB) .* double(B)) * 127 / (255 - double(medianB)));
    downscaleB = max(0, downscaleB);
    maintainB = (B == medianB) .* double(B);
    normalizedB = uint8(upscaleB + downscaleB + maintainB);
    imgTraining = cat(3, normalizedR, normalizedG, normalizedB);
    imgTraining = imresize(imgTraining, imgSize);    
    featuresTraining(i, :) = extractHOGFeatures(imgTraining);    
end  
% SVM(support vector machine).
classifer = fitcecoc(featuresTraining, imdsTraining.Labels); 
%%
% imdsTest = imageDatastore('./../Testing/', 'IncludeSubfolders', true);
% testImage = readimage(imdsTest,100);   
% scaledTestImage = imresize(testImage,imgSize); 
% featureTest = extractHOGFeatures(scaledTestImage); 
% [predictIndex,score] = predict(classifer,featureTest); 
% figure;imshow(testImage);  
% title(['predictImage: ',char(predictIndex)]);