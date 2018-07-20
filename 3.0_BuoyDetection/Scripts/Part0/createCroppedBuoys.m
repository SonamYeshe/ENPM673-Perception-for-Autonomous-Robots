% Param: should be a number among 1, 2, 3, representing yellow, red, green.
function createCroppedBuoys(color)
    if color == 1
        filenameBase = '../../Images/TrainingSet/CroppedBuoys/Y_';
    elseif color == 2
        filenameBase = '../../Images/TrainingSet/CroppedBuoys/R_';
    elseif color == 3
        filenameBase = '../../Images/TrainingSet/CroppedBuoys/G_';
    end 
    imagePath = '../../Images/TrainingSet/Frames';
    disp('');
    disp('INTRUCTION: Click along the boundary of the ball. Double-click when you get back to the initial point.')
    disp('INTRUCTION: You can maximize the window size of the figure for precise clicks.')
    Samples = [];
    % Yellow shows from 1 to 200.
    % Red shows from 1 to 145 & 175 to 200.
    % Green shows from 1 to 43.
    for i = 1 : 43
        % Load original frames.
        filename = sprintf('%d.jpg', i);
        fullFilename = fullfile(imagePath, filename);
        frame = imread(fullFilename);  
        % Denoise frames.
        R = frame(:,:,1);
        G = frame(:,:,2);
        B = frame(:,:,3);
        R = medfilt2(R, [3 3]);
        G = medfilt2(G, [3 3]);
        B = medfilt2(B, [3 3]);
        frameDenoised = cat(3, R, G, B);
        % Manually select buoy cropped samples.
        figure(1), 
        mask = roipoly(frameDenoised);
        % Save rgb values in the cropped area.
        croppedR = double(frameDenoised(:,:,1)) .* mask;
        croppedG = double(frameDenoised(:,:,2)) .* mask;
        croppedB = double(frameDenoised(:,:,3)) .* mask;
        croppedFrame = frameDenoised;
        croppedFrame(:,:,1) = croppedR;
        croppedFrame(:,:,2) = croppedG;
        croppedFrame(:,:,3) = croppedB;
    %     figure(2), imshow(mask); title('Mask');
        % Save image. Imwrite changes the GRB values!
        filenameNum =sprintf('%d.jpg', i);
        fullFilename = strcat(filenameBase, filenameNum);
        imwrite(mat2gray(croppedFrame), fullFilename, 'jpg');
        % Save rgb values in the cropped area. 
        sampleIndex = find(mask > 0);
        R = R(sampleIndex);
        G = G(sampleIndex);
        B = B(sampleIndex);
        Samples = [Samples; [R G B]];
    end
    if color == 1
        save('YellowSamples.mat', 'Samples');
    elseif color == 2
        save('RedSamples.mat', 'Samples');
    elseif color == 3
        save('GreenSamples.mat', 'Samples');
    end 
end