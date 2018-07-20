% clear all
% %% Generate parameters of 3 1D gaussians.
% mean1 = 1;
% mean2 = 3;
% mean3 = -2;
% std1 = 0.5;
% std2 = 2;
% std3 = 5;
% %% Get 10 samples from each of these.
% x1 = normrnd(mean1, std1,[10,1]);
% x2 = normrnd(mean2, std2,[10,1]);
% x3 = normrnd(mean3, std3,[10,1]);
% x = sort([x1;x2;x3]);
% %% Predefine samples # in each set.
% N = 30;
% pi1 = 10 / N;
% pi2 = 10 / N;
% pi3 = 10 / N;
% %% Initial guess.
% mean1 = 0;
% mean2 = -2;
% mean3 = 8;
% std1 = 3;
% std2 = 1;
% std3 = 10;
% 
% for i = 1 : 100
%     %% E step start.
%     Npdf1 = normpdf(x,mean1,std1);
%     Npdf2 = normpdf(x,mean2,std2);
%     Npdf3 = normpdf(x,mean3,std3);
%     Z = pi1 * Npdf1 + pi2 * Npdf2 + pi3 * Npdf3;
%     z1 = Npdf1 * pi1 ./ Z;
%     z2 = Npdf2 * pi2 ./ Z;
%     z3 = Npdf3 * pi3 ./ Z;
%     % plot(x,Z)
%     % hold on
%     %% Finish M step to update parameters.
%     pi1 = sum(z1(:, 1))/N;
%     pi2 = sum(z2(:, 1))/N;
%     pi3 = sum(z3(:, 1))/N;
%     mean1 = sum(z1 .* x) / sum(z1(:, 1));
%     mean2 = sum(z2 .* x) / sum(z2(:, 1));
%     mean3 = sum(z3 .* x) / sum(z3(:, 1));
% %     var1 = sum(z1 .* (x - mean1)' * (x - mean1)) / sum(z1(:, 1));
% %     var2 = sum(z2 .* (x - mean2)' * (x - mean2)) / sum(z2(:, 1));
% %     var3 = sum(z3 .* (x - mean3)' * (x - mean3)) / sum(z3(:, 1));
%     var1 = sum(z1 .* (x - mean1).^ 2) / sum(z1(:, 1));
%     var2 = sum(z2 .* (x - mean2).^ 2) / sum(z2(:, 1));
%     var3 = sum(z3 .* (x - mean3).^ 2) / sum(z3(:, 1));
%     std1 = sqrt(var1);
%     std2 = sqrt(var2);
%     std3 = sqrt(var3);
% end

clear all
NSampleTot = 10;
NSample = [];
for i = 1 : 3
    NSample = cat(1, NSample, NSampleTot);
end


% %% Take 4 1D gaussians
% mu_1 = 0;
% mu_2 = 3;
% mu_3 = 6;
% mu_4 = 9;
% sigma_1 = 2;
% sigma_2 = 0.5;
% sigma_3 = 3;
% sigma_4 = 1.5;
% %% Get samples from each of these
% y_1 = normrnd(mu_1, sigma_1,[50,1]);
% y_2 = normrnd(mu_2, sigma_2,[50,1]);
% y_3 = normrnd(mu_3, sigma_3,[50,1]);
% y_4 = normrnd(mu_4, sigma_4,[50,1]);
% %% Sort the samples and plot it against mean of the three gaussians
% X = sort([y_1;y_2;y_3;y_4]); % The samples
% Y = (normpdf(X,mu_1,sigma_1) + normpdf(X,mu_2,sigma_2) + normpdf(X,mu_3,sigma_3) + normpdf(X,mu_4,sigma_4)) ./ 4;
% plot(X,Y)
% hold on
% %% Fit a GMM and look at how good the computation is
% gmmmodel = fitgmdist(X, 4);
% Y_gmm = pdf(gmmmodel,X);
% plot(X, Y_gmm, 'r');






% clear all
% GaussiansNumber=3;
% %% sample 
% mu_1 = 1;
% mu_2 = 3;
% mu_3 = -2;
% sigma_1 = 1;
% sigma_2 = 0.5;
% sigma_3 = 2;
% y_1 = normrnd(mu_1, sigma_1,[10,1]);
% y_2 = normrnd(mu_2, sigma_2,[10,1]);
% y_3 = normrnd(mu_3, sigma_3,[10,1]);
% X = sort([y_1;y_2;y_3]); % The samples
% %% initial guess
% mu_1 = 0;
% mu_2 = 5;
% mu_3 = 1;
% sigma_1 = 1;
% sigma_2 = 1;
% sigma_3 = 1;
% iteration=1;
% iterationMax=100;
% 
% pi_1=1/3;
% pi_2=1/3;
% pi_3=1/3;
% 
% %%
% while(iteration<iterationMax)
%  
%    %% E-step
%    px_1=normpdf(X,mu_1,sqrt(sigma_1));
%    px_2=normpdf(X,mu_2,sqrt(sigma_2));
%    px_3=normpdf(X,mu_3,sqrt(sigma_3));
%    Zi=px_1*pi_1+pi_2*px_2+pi_3*px_3;
%      
%    zi1=(1./Zi).*px_1*pi_1;
%    zi2=(1./Zi).*px_2*pi_2;
%    zi3=(1./Zi).*px_3*pi_3;
% %     for i=1:30
% %     [~, fromWhichGM(i)]=max(responsibility(i,:));
% %     end
%    %% M-step
%    % update pi    
%    mu_1 = sum(zi1.*X)/sum(zi1);
%    mu_2 = sum(zi2.*X)/sum(zi2);
%    mu_3 = sum(zi3.*X)/sum(zi3);
%    sigma_1 = sum(zi1.*(X-mu_1).^2)/sum(zi1);
%    sigma_2 = sum(zi2.*(X-mu_2).^2)/sum(zi2);
%    sigma_3 = sum(zi3.*(X-mu_3).^2)/sum(zi3);
%    pi_1=sum(zi1)/30;
%    pi_2=sum(zi2)/30;
%    pi_3=sum(zi3)/30;
%    
%    iteration=iteration+1;
% end







% %% Fit a GMM and look at how good the computation is
% gmmmodel = fitgmdist(x, 3);
% Y_gmm = pdf(gmmmodel,x);
% plot(x, Y_gmm, 'r')

% clear all
% %% Generate parameters of 3 1D gaussians.
% mean1 = 0;
% mean2 = 3;
% mean3 = -2;
% std1 = 1;
% std2 = 0.5;
% std3 = 2;
% %% Get 10 samples from each of these.
% x1 = normrnd(mean1, std1,[10,1]);
% x2 = normrnd(mean2, std2,[10,1]);
% x3 = normrnd(mean3, std3,[10,1]);
% x = sort([x1;x2;x3]);
% data = x;
% 
% N = 3;
% %% start the EM loop
% mean = rand([3, 1]);
% % mean = [-5; 0; 5];
% std = 10 * rand([3, 1]);
% % Predefine samples # in each set.
% NSample = [10; 10; 10];
% NSampleTot = sum(NSample);
% pi = NSample / NSampleTot;
% 
% Npdf = zeros(NSampleTot, N);
% for k = 1 : N
%     Npdf(:, k) = normpdf(data, mean(k), std(k));
% end
% Z = zeros(NSampleTot, 1);
% for k = 1 : N
%     Z = Z + pi(k) * Npdf(:, k);
% end
% z = zeros(NSampleTot, N);
% for k = 1 : N
%     z(:, k) = Npdf(:, k) * pi(k) ./ Z;
% end
% %% M step to update parameters.
% var = zeros(N, 1);
% for k = 1 : N
%     NSample(k) = sum(z(:, k));
%     mean(k) = sum(z(:, k) .* data) / NSample(k);
%     var(k) = sum(z(:, k) .* (data - mean(k))' * (data - mean(k))) / NSample(k);
%     std(k) = sqrt(var(k));
% end
% % count = zeros(N,1);
% % for j = 1 : NSampleTot
% %     zCompare = [z(j, 1); z(j, 2); z(j, 3)];
% %     zCompare = sort(zCompare);
% %     if zCompare(3) == z(j, 1)
% %         count(1) = count(1) + 1;
% %     elseif zCompare(3) == z(j, 2)
% %         count(2) = count(2) + 1;
% %     else
% %         count(3) = count(3) + 1;
% %     end
% % end
% % NSample = count;
% pi = NSample / NSampleTot;