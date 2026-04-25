clear;
clc;
close all;

fprintf('--------- Part A ---------\n')
tspan = [0 10];

b = 0.8;
y0 = [0; 1];

% Now solve using ode45
[t,y] = ode45(@(t,y) particleODE(t,y,b), tspan, y0);
% Some special formatting to hide b inside of the function that just takes t and y as inputs
x = y(:,1);
v = y(:,2);

% First plot x(t)
subplot(2,1,1)
plot(t, x, 'g', 'LineWidth', 2)
grid on
xlabel('t (s)')
ylabel('x(t) [m]')
title('Position vs time')

subplot(2,1,2)
plot(t, v, 'r', 'LineWidth',2)
grid on
xlabel('t [s]')
ylabel('v(t) [m/s]')
title('Velocity vs time')

% Find the first time x crosses -1
Target = -1;
idx = find((x(1 : end-1) - Target).*(x(2 : end) - Target) <= 0, 1);
% Find the first pair of points where x crosses -1
tx = interp1(x(idx:idx+1), t(idx:idx+1), Target);
v_tx = interp1(t(idx:idx+1), v(idx:idx+1), tx);
% Forces matlab to use the two points where x first crosses -1, since it is a sign wave

fprintf('Velocity when particle is at x = -1: %.3f m/s\n\n', v_tx);

[vmax, idxMax] = max(v);
% Should return the maximum velocity, and the index at which the max occurs

x_at_vmax = x(idxMax);

fprintf('--------- Part B ---------\n')
fprintf('Position where velocity is maximal: %.3f m\n', x_at_vmax);
fprintf('Maximum velocity: %.3f m/s\n', vmax);

function dydt = particleODE(~,y,b)
dydt = zeros(2,1);
dydt(1) = y(2);                     % v (velocity)
dydt(2) = -(0.1 + sin(y(1)/b));      % a (accel)

end
