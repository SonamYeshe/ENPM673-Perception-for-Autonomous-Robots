function [YBuoyMean, YBuoyStd, RBuoyMean, RBuoyStd, GBuoyMean, GBuoyStd] = EMParamExtractor(yo)
    if nargin == 0
        addpath('../Part1/');
        load '../../Images/TrainingSet/YellowSamples'
        YBuoy = cat(1, Samples(:, 1), Samples(:, 2), Samples(:, 3));
        YBuoy = sort(YBuoy);
        [YBuoyMean, YBuoyStd] = EM(3, YBuoy, 1);
        load '../../Images/TrainingSet/RedSamples'
        RBuoy = cat(1, Samples(:, 1), Samples(:, 2), Samples(:, 3));
        RBuoy = sort(RBuoy);
        [RBuoyMean, RBuoyStd] = EM(3, RBuoy, 1);
        load '../../Images/TrainingSet/GreenSamples'
        GBuoy = cat(1, Samples(:, 1), Samples(:, 2), Samples(:, 3));
        GBuoy = sort(GBuoy);
        [GBuoyMean, GBuoyStd] = EM(3, GBuoy, 1);
    else
        % If function is called with a param, don't show the plot.
        addpath('../Part1/');
        load '../../Images/TrainingSet/YellowSamples'
        YBuoy = cat(1, Samples(:, 1), Samples(:, 2), Samples(:, 3));
        YBuoy = sort(YBuoy);
        [YBuoyMean, YBuoyStd] = EM(3, YBuoy);
        load '../../Images/TrainingSet/RedSamples'
        RBuoy = cat(1, Samples(:, 1), Samples(:, 2), Samples(:, 3));
        RBuoy = sort(RBuoy);
        [RBuoyMean, RBuoyStd] = EM(3, RBuoy);
        load '../../Images/TrainingSet/GreenSamples'
        GBuoy = cat(1, Samples(:, 1), Samples(:, 2), Samples(:, 3));
        GBuoy = sort(GBuoy);
        [GBuoyMean, GBuoyStd] = EM(3, GBuoy);
    end
end