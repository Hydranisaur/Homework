
% Step 2
t = linspace(-2, 2, 25);   % Basically the same, just with the adjusted range
y = linspace(-2, 2, 25);
[T, Y] = meshgrid(t, y);

% Step 3 
dy = f(T, Y);
dt = ones(size(dy));

% Step 4
norm = sqrt(dt.^2 + dy.^2);
dy_u = dy ./ norm;
dt_u = dt ./ norm;

% Step 5 - Plotting
figure
quiver(T, Y, dt_u, dy_u, 'b')
grid on
xline(0)
yline(0)
% Adds the axis lines
xlabel('t')
ylabel('y')
% Labels the axis
xlim([-2 2])
ylim([-2 2])
% Adds the limits to the fiure
title("Direction Field for y' = 4y + 5e^t")

% Now to overlay the initial value solution
hold on

tplot = linspace(-2, 2, 400)
yplot = (11/3)*exp(4*tplot) - (5/3)*exp(tplot)
plot(tplot, yplot, 'r', 'LineWidth', 2)

% Step 1
function z =  f(t, y)
    z = 4*y + 5 * exp(t);
end

