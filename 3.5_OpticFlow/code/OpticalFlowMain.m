clear all
clc
close all
% Load images.
% addpath('./../dataset/eval-data-gray/Wooden/');
addpath('./../dataset/eval-data-gray/Grove/');
% Extract images dataset.
% images.filename = ls('./../dataset/eval-data-gray/Wooden/*.png');
images.filename = ls('./../dataset/eval-data-gray/Grove/*.png');
numImages = size(images.filename, 1); 
% Open video writer, prepare for recording.
% vid = VideoWriter('Wooden_LK', 'MPEG-4');
vid = VideoWriter('Grove_LK', 'MPEG-4');
vid.FrameRate = 3;
open(vid);
for k = 1 : numImages - 1
    image1 = imread(images.filename(k, :));
    image2 = imread(images.filename(k+1, :));
    image1 = im2double(image1);
    image2 = im2double(image2);
    % Calculate gradients.
    [Ix, Iy] = imgradientxy(image1); % G_x = [1 0 -1; 2 0 -2; 1 0 -1]; G_y = [1 2 1; 0 0 0; -1 -2 -1].
    It = double(image2 - image1);
    % Assume velocity of pixels in the window are the same.
    windowSize = 41; % 41*41 pixel window
    halfWindowSize = floor(windowSize / 2); % =20
    u = zeros(size(image1));
    v = zeros(size(image1));
    for i = round(windowSize / 2) : size(image1, 1) - halfWindowSize
        for j = round(windowSize / 2) : size(image1, 2) - halfWindowSize
            IxWindow = Ix(i - halfWindowSize : i + halfWindowSize, j - halfWindowSize : j + halfWindowSize);
            IyWindow = Iy(i - halfWindowSize : i + halfWindowSize, j - halfWindowSize : j + halfWindowSize);
            ItWindow = It(i - halfWindowSize : i + halfWindowSize, j - halfWindowSize : j + halfWindowSize);
            IxWindow = IxWindow(:);
            IyWindow = IyWindow(:);
            b = -ItWindow(:);
            A = [IxWindow IyWindow];
            % Calculate the window velocity and assign it to the pixels.
            % A*v=b --> A^t*A*v=A^t*b --> v = (A^t*A)^(-1) * A^t*b
            uv = [sum(IxWindow .^ 2) sum(IxWindow .* IyWindow); sum(IyWindow .* IxWindow) sum(IyWindow .^ 2)] ...
                 \ [sum(IxWindow .* b); sum(IyWindow .* b)];
            u(i, j) = uv(1);
            v(i, j) = uv(2);
        end
    end
    % downsize u and v to smooth results.
    scale = 25;
    uu = u(1:scale:end, 1:scale:end);
    vv = v(1:scale:end, 1:scale:end);
    [x,y] = meshgrid(0:scale:size(image1, 2), 0:scale:size(image1, 1));
    x=x+1;
    y=y+1;
    % Plot.
    figure(1);
    imshow(image1);
    hold on;
    quiver(x, y, uu, vv, 'y')
    % Record video
    frame = getframe(gca);
    writeVideo(vid, frame); 
end
close(vid)