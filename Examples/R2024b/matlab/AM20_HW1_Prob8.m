
% Step 2
x = linspace(-2, 2, 20);   % Basically the same, just with the adjusted range
y = linspace(-2, 2, 20);
[X, Y] = meshgrid(x, y);

% Step 3 
dy = f(X, Y);
dx = ones(size(dy));

% Step 4
norm = sqrt(dx.^2 + dy.^2);
dy_u = dy ./ norm;
dx_u = dx ./ norm;

% Step 5
figure('Position', [100 100 800 600])
% Copies the figure formatting
quiver(X, Y, dx_u, dy_u)
% Same as in python, plots the slopes at every (X, Y) cordinate with the vector (dx_u, dy_u)
grid on
xline(0)
yline(0)
% Adds the axis lines
xlabel('x')
ylabel('y')
% Labels the axis
xlim([-2 2])
ylim([-2 2])
% Adds the limits to the fiure
title("Direction Field for y' = \frac{x^2 + y^2}{1 - x^2 - y^2}", 'Interpreter', 'latex')

% Step 1
function z =  f(x, y)
    z = (x.^2 + y.^2) ./ (1 - x.^2 - y.^2);
end

