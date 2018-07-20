function [mean, std] = EM(N, data, plot_path)
    mean = 255 * rand([N, 1]);
    std = 255 * rand([N, 1]);
    % Predefine samples # in each set.
    NSampleTot = length(data);
    NSample = [];
    for i = 1 : N
        NSample = cat(1, NSample, NSampleTot / N);
    end
    pi = NSample / NSampleTot;
    nIteration = 100;
    data = double(data);
    for i = 1 : nIteration
        %% E step to estimate the propability for data point to come from each distribution.
        Npdf = zeros(NSampleTot, N);
        for k = 1 : N
            Npdf(:, k) = normpdf(data, mean(k), std(k));
        end
        Z = zeros(NSampleTot, 1);
        for k = 1 : N
            Z = Z + pi(k) * Npdf(:, k); 
        end
        z = zeros(NSampleTot, N);
        for k = 1 : N
            z(:, k) = Npdf(:, k) * pi(k) ./ Z;
        end
        %% M step to update parameters(pi, mu and sigma).
        var = zeros(N, 1);
        for k = 1 : N
            NSample(k) = sum(z(:, k));
            mean(k) = sum(z(:, k) .* data) / NSample(k);
            var(k) = sum(z(:, k) .* (data - mean(k)) .^ 2) / NSample(k);
            std(k) = sqrt(var(k));
        end
        pi = NSample / NSampleTot;
        if i == nIteration
            disp(mean);
            disp(std);
            disp(pi);
            if nargin == 3
                figure
                plot(data, Z, 'b')
                legend('Result by my implementation of EM.')
            end
        end
    end
end
