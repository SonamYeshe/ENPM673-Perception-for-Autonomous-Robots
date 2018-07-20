vidReader = VideoReader('Wooden_Raw.mp4','CurrentTime',1);
opticFlow = opticalFlowFarneback;
while hasFrame(vidReader)
    frameRGB = readFrame(vidReader);
    frameGray = rgb2gray(frameRGB);

    flow = estimateFlow(opticFlow,frameGray); 

    imshow(frameRGB) 
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',2)
    hold off 
end