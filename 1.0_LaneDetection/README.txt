## Lane Detection

# General

Our goal is piece together a pipeline to detect the line segments in the image, then average/extrapolate them and draw them onto the image for display. Once we have a working pipeline, we try it out on the video stream.

# Run

1. Run LaneDetecterForProjectVideo.m or LaneDetecterForChallengeVideo.m directly, the output video will in the Code folder. It will not go into Output folder automatively in case of replacign the existing output video.

# Notice

1. License file is for arrow.m. It's a open source function to create arrow.
2. The 2 detection matlab files have a few different parameters. Don't mess up with them.
3. All codes are commented, you cantake a look at the brief introduction of the ideas in the report and go into the code.