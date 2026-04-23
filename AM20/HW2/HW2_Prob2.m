
% Step 2
t = linspace(-3, 3, 25);   % Basically the same, just with the adjusted range
y = linspace(-3, 3, 25);
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
xlim([-3 3])
ylim([-3 3])
% Adds the limits to the fiure
title("Direction Field for y' = -5/17sin(2t) - 20/17cos(2t) + 37/17e^(t/2)")

% Now to overlay the initial value solution
hold on

tplot = linspace(-3, 3, 400)
yplot = (-5/17)*sin(2*tplot) - (20/17)*cos(2*tplot) + (37/17)*exp(tplot/2)
plot(tplot, yplot, 'r', 'LineWidth', 2)

% Step 1
function z =  f(t, y)
    z = y/2 + (5/2)*sin(2*t);
end

