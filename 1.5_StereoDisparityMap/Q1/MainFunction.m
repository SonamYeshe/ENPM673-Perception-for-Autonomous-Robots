clear all
clc
% Define all the inout parameters.
X = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
theta = 20 / 180 * pi;
R1 = [1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];
R2 = [0 -1 0; -1 0 0; 0 0 -1];
R = R1 * R2;
T = [0; 0; 3];
K = [800 0 250; 0 800 250; 0 0 1];

% Retrieve the vertex positions.
x = project(X, R, T, K);
figure, hold on
for i = size(x, 2)
    plot(x(1,:), x(2,:), '*r','MarkerSize',10);
end

% Connect the vertex with lines for more apparent visulization.
xx = x(1, 1 : 2);
yy = x(2, 1 : 2);
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');
xx = x(1, 2 : 3);
yy = x(2, 2 : 3);
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');
xx = x(1, 3 : 4);
yy = x(2, 3 : 4);
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');
xx = x(1, 5 : 6);
yy = x(2, 5 : 6);
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');
xx = x(1, 6 : 7);
yy = x(2, 6 : 7);
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');
xx = x(1, 7 : 8);
yy = x(2, 7 : 8);
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');

xx = x(1, 1);
xx = cat(1, xx, x(1, 4));
yy = x(2, 1);
yy = cat(1, yy, x(2, 4));
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');
xx = x(1, 5);
xx = cat(1, xx, x(1, 8));
yy = x(2, 5);
yy = cat(1, yy, x(2, 8));
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');

xx = x(1, 1);
xx = cat(1, xx, x(1, 5));
yy = x(2, 1);
yy = cat(1, yy, x(2, 5));
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');
xx = x(1, 2);
xx = cat(1, xx, x(1, 6));
yy = x(2, 2);
yy = cat(1, yy, x(2, 6));
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');
xx = x(1, 3);
xx = cat(1, xx, x(1, 7));
yy = x(2, 3);
yy = cat(1, yy, x(2, 7));
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');
xx = x(1, 4);
xx = cat(1, xx, x(1, 8));
yy = x(2, 4);
yy = cat(1, yy, x(2, 8));
plot(xx, yy, 'LineWidth', 1, 'Color', 'g');
axis equal;