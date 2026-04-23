clear;
close all;

tspan = [0 10];

% Define ICs

%y(1) = x;
%y(2) = xdot;
y0 = [-40; -36];

% Now solve using ode45
[t,y] = ode45(@particleODE, tspan, y0);

x = y(:,1);
xdot = y(:,2);
% Essentially extract the first row and second row components from y to be
% x and xdot

% First plot x(t)
subplot(2,1,1)
plot(t, x, 'g', 'LineWidth', 2)
grid on
xlabel('t (s)')
ylabel('x (ft)')
title('Displacement over time')

subplot(2,1,2)
plot(t, xdot, 'r', 'LineWidth',2)
grid on
xlabel('t (s)')
ylabel('dx/dt (ft/s)')
title('Velocity over time')


function dydt = particleODE(t,y)
dydt = zeros(2,1);
dydt(1) = y(2);
dydt(2) = 6*t - 12;
end