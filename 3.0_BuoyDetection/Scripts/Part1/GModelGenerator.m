clear all
% Generate parameters of 3 1D gaussians.
mean1 = 1;
mean2 = 3;
mean3 = 6;
std1 = 1;
std2 = 0.5;
std3 = 2;
% Get 10 samples from each of these.
x1 = normrnd(mean1, std1, [10, 1]);
x2 = normrnd(mean2, std2, [10, 1]);
x3 = normrnd(mean3, std3, [10, 1]);
x = sort([x1; x2; x3]);
% Fit a GMM and look at how good the computation is
gmmModel = fitgmdist(x, 3);
YGMM = pdf(gmmModel, x);
figure (1)
hold on
plot(x, YGMM, 'r')
% Run the EM function.
data = x;
% for EM1D3N.jpg
N = 3;
% % for EM1D4N.jpg
% N = 4;
plot_path = 1;
EM(N, data, plot_path);
% % Or you can call this without showing the plot by my implementation.
% EM(N, data);